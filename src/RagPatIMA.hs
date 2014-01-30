{-# OPTIONS_GHC -Wall                   #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Main where

import ZMidi.Score         hiding (numerator, denominator)
import ZMidi.IO.Common          ( readQMidiScoreSafe, mapDirInDir, mapDir, warning )
import ZMidi.Skyline.MelFind                      ( mergeTracks )
import Ragtime.TimeSigSeg
import IMA.InnerMetricalAnalysis hiding ( Time )
import qualified IMA.InnerMetricalAnalysis as IMA ( Time )
import System.Environment           ( getArgs )
import Data.List            ( nubBy, intercalate, foldl' )
import Data.Ratio                   ( numerator, denominator )
import Data.Function                ( on )
import Data.Map.Strict             ( empty, Map, insertWith, foldrWithKey, unionWith, toList  )
import Data.Binary                 ( Binary, encodeFile )
import Control.Arrow               ( first )
import Text.Printf

-- | Normalised spectral weights (value between 0 and 1)
newtype NSWeight = NSWeight { nsweight :: Double }
                     deriving ( Eq, Show, Num, Ord, Enum, Real, Floating
                              , Fractional, RealFloat, RealFrac, PrintfArg
                              , Binary )
                              
type NSWMeterSeg = TimedSeg TimeSig [Timed (Maybe ScoreEvent, NSWeight)]

-- TODO create a MPMidiScore for monophonic MidiScores
-- TODO create a QMPMidiScore for quantised monophonic MidiScores

-- matchMeterIMA :: ShortestNote -> MidiScore -> Either String [NSWMeterSeg]
-- matchMeterIMA sn = either Left matchMeterQIMA . quantiseSafe sn

doIMA :: QMidiScore -> Either String [NSWMeterSeg]
doIMA qms = 
  let v    = toMonoVoice . qMidiScore $ qms
      md   = fromIntegral . minDur . qMidiScore $ qms
  in     return (toIMAOnset v)
     >>= addMaxPerCheck 
     >>= return . getSpectralWeight md
     >>= return . matchScore v
     >>= return . segment (getTimeSig . qMidiScore $ qms)
                

-- merges all tracks and applies 'makeMono' to the result
toMonoVoice :: MidiScore -> Voice 
toMonoVoice = makeMono . head . getVoices . mergeTracks where

  -- filters NoteEvents, and deletes events with the same onset time
  makeMono :: Voice -> Voice 
  -- TODO : we should be able to use Data.List.Ordered, but this nub give
  -- other results, this must be investigated
  makeMono = nubBy ((==) `on` onset) . filter isNoteEvent
      
-- Transforms a 'Voice' into a list of IMA onsets
toIMAOnset :: Voice -> [IMA.Time]
toIMAOnset = map fromIntegral . toOnsets 

-- combines a 'Voice' with its spectral weights
matchScore :: Voice -> [(Int, SWeight)] -> [Timed (Maybe ScoreEvent, NSWeight)]
matchScore v s = match (fromIntegral . maximum . map snd $ s) (map (first Time) s) v where
      
  -- | matches a grid with spectral weights with the onsets that created the
  -- weights. The first argument is the maximum 'Weight' found among the weights
  match :: NSWeight -> [(Time, SWeight)] -> Voice 
        -> [Timed (Maybe ScoreEvent, NSWeight)]
  match _ [] []              = []
  match m ((g, w):ws) []     =          addWeight m w (Left g) : match m ws []
  match m ((g, w):ws) (t:ts) | g <  o = addWeight m w (Left g) : match m ws (t:ts)
                             | g == o = addWeight m w (Right t): match m ws ts
                             | otherwise = error "unmatched onset"
                                 where o = onset t
  match _ _ _                = error "list of unequal lengths"             

  addWeight :: NSWeight -> SWeight -> Either Time (Timed ScoreEvent) 
            -> Timed (Maybe ScoreEvent, NSWeight)
  addWeight m w e = either ((flip Timed) (Nothing, w')) f e
    where w'  = fromIntegral w / m
          f t = t {getEvent = (Just $ getEvent t, w')}

--
starMeter :: Time -> NSWMeterSeg -> IO ()
starMeter tpb (TimedSeg (Timed t ts) s) = 
  do putStrLn (show t ++ " ================== " ++ show ts ++ " ==================" )
     mapM_ (toStar t ts) s where
                    
  -- prints one line e.g. "1152 1 3 1C  ***************"
  toStar :: Time -> TimeSig -> Timed (Maybe ScoreEvent, NSWeight) -> IO ()
  toStar os x (Timed g (se,w)) = 
    let (b, BarRat r) = getBeatInBar x tpb g
    in putStrLn (printf ("%6d: %3d - %2d / %2d: " ++ showMSE se ++ ": " ++ stars w) 
                (g+os) b (numerator r) (denominator r)) 
                
  showMSE :: Maybe ScoreEvent -> String
  showMSE = maybe "   " (show . pitch) 

stars :: NSWeight -> String
stars w = replicate (round (20 * w)) '*' 

--------------------------------------------------------------------------------
-- IMA profiles
--------------------------------------------------------------------------------

-- | Normalised Spectral Weight Profiles
type NSWProfSeg  = TimedSeg TimeSig NSWProf
type NSWProf     = (NrOfBars, Map BarRat NSWeight)

-- | Stores the number of bars
newtype NrOfBars = NrOfBars  { nrOfBars :: Int }
                    deriving ( Eq, Show, Num, Ord, Enum, Real, Integral, PrintfArg, Binary )

toNSWProfSegs :: QMidiScore -> Either String [NSWProfSeg]
toNSWProfSegs m = doIMA m >>= return . map (toNSWProf (ticksPerBeat . qMidiScore $ m))

-- | Calculates sums the NSW profiles for a meter section
toNSWProf :: Time ->  NSWMeterSeg -> NSWProfSeg
toNSWProf tpb (TimedSeg ts s) = TimedSeg ts (foldl' toProf (1,empty) s) where

  toProf :: NSWProf -> Timed (Maybe ScoreEvent, NSWeight) -> NSWProf
  toProf (_b, m) (Timed g (_se,w)) = 
    let (br, bt) = getBeatInBar (getEvent ts) tpb g 
        m'       = insertWith (+) bt w m 
    in  m' `seq` (fromIntegral br, m')

-- | Plots an 'NSWProf'ile by calculating the average profile
showNSWProf :: (TimeSig, NSWProf) -> String
showNSWProf (ts, (bars, m)) = intercalate "\n" ( show ts : foldrWithKey shw [] m )

  where shw :: BarRat -> NSWeight -> [String] -> [String]
        shw (BarRat br) w r = let x = w / fromIntegral bars
                              in (printf ("%2d / %2d: %.3f" ++ stars x) 
                                 (numerator br) (denominator br) x   ) : r

-- | Collects all profiles sorted by time signature in one map
collectNSWProf :: [NSWProfSeg] -> Map TimeSig NSWProf -> Map TimeSig NSWProf
collectNSWProf s m = foldr doSeg m s where

  doSeg :: NSWProfSeg -> Map TimeSig NSWProf -> Map TimeSig NSWProf
  doSeg (TimedSeg ts p) m' = insertWith mergeNSWProf (getEvent ts) p m'
  
-- | merges two 'NSWProf's by summing its values
mergeNSWProf :: NSWProf -> NSWProf -> NSWProf
mergeNSWProf (a, ma) (b, mb) = let m = unionWith (+) ma mb in m `seq` (a + b, m)

--------------------------------------------------------------------------------
-- exporting / importing IMA profiles
--------------------------------------------------------------------------------

safeNSWProf :: FilePath -> Map TimeSig NSWProf -> IO (Map TimeSig NSWProf)
safeNSWProf fp m = encodeFile fp m >> putStrLn ("written: " ++ fp) >> return m
  
-- testing
main :: IO ()
main = 
  do arg <- getArgs 
     case arg of
       ["-f", fp] -> do x <- readQMidiScoreSafe FourtyEighth fp 
                        let ms = either error id x
                        -- does the file contains disruptive onsets?
                        case doIMA ms of 
                          Right s -> 
                            do let tpb = ticksPerBeat (qMidiScore ms)
                               -- putStrLn ("Ticks per beat: " ++ show tpb)
                               putStrLn ("Quantisation deviation: " ++ show (avgQDevQMS ms))
                               mapM_ (starMeter tpb) s
                               printMeterStats . collectNSWProf 
                                  (map (toNSWProf tpb) s) $ empty
                          Left e      -> putStrLn e -- show the error
                            
       ["-a", fp] -> do mapDirInDir (\x -> mapDir readProf x >>= unionNWProfMaps) fp
                            >>= unionNWProfMaps >>= safeNSWProf "nswProf.bin" 
                            >>= printMeterStats
                            
       ["-d", fp] -> do     mapDir readProf fp >>= unionNWProfMaps 
                        >>= safeNSWProf "nswProf.bin" >>= printMeterStats    
                        
       _    -> error "Please use -f <file> or -d <ragtime directory>"
   
unionNWProfMaps :: [Map TimeSig NSWProf] -> IO (Map TimeSig NSWProf)
unionNWProfMaps m = do let r = foldr (unionWith mergeNSWProf) empty m
                       r `seq` return r


printMeterStats :: Map TimeSig NSWProf -> IO ()
printMeterStats = mapM_ (putStrLn . showNSWProf) . toList 
   
readProf :: FilePath -> IO (Map TimeSig NSWProf)
readProf fp = do qm <- readQMidiScoreSafe FourtyEighth fp 
                 case qm >>= qMidiScoreToNSWProfMaps of
                   Right w -> return w
                   Left  e -> warning fp e >> return empty
                 
qMidiScoreToNSWProfMaps :: QMidiScore -> Either String (Map TimeSig NSWProf)
qMidiScoreToNSWProfMaps qms =     timeSigCheck qms 
                              >>= toNSWProfSegs
                              >>= (\x -> return $ collectNSWProf x empty)
       
timeSigCheck :: QMidiScore -> Either String QMidiScore
timeSigCheck ms | hasTimeSigs (qMidiScore ms) = Right ms
                | otherwise = Left "Has no valid time signature"

 