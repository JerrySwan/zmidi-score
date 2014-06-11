{-# OPTIONS_GHC -Wall                   #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
-- | applying the Inner Metric Analysis to Midi files ('ZMidi.Score')
module Ragtime.MidiIMA ( SWMeterSeg
                       , fourBarFilter
                       , emptySegFilter
                       , collectSWProf
                       , toSWProfSegs 
                       , printIMA
                       -- | * Utilities
                       , doIMA
                       , toNSWProfWithTS
                       , toSWProf
                       ) where

import Ragtime.NSWProf 
import ZMidi.Score         hiding ( numerator, denominator )
import ZMidi.Skyline.MelFind      ( mergeTracks )
import Ragtime.TimeSigSeg         ( TimedSeg (..), segment )

import IMA.InnerMetricalAnalysis hiding           ( Time(..) )
import qualified IMA.InnerMetricalAnalysis as IMA ( Time(..) )

import Data.List                   ( nubBy, foldl' )
import Data.Function               ( on )
import Data.Map.Strict             ( empty, Map, insertWith )
import Control.Arrow               ( first )

import Text.Printf                 ( printf )
import Data.Ratio                  ( numerator, denominator, )

--------------------------------------------------------------------------------
-- Calculate Spectral Weight Profiles
--------------------------------------------------------------------------------

data IMAnalysis = SWMeterStore { swMeterSeg :: SWMeterSeg
                               , imaFile    :: FilePath
                               } deriving (Show, Eq)
                    
  
-- A type synonym that captures all IMA information needed for meter estimation
type SWMeterSeg = TimedSeg TimeSig [Timed (Maybe ScoreEvent, SWeight)]

-- A type synonym for a Segment in which the IMA info has been compressed into
-- an Spectral Weight profile
type SWProfSeg = TimedSeg TimeSig SWProf

-- | Collects all profiles sorted by time signature in one map
collectSWProf :: [SWProfSeg] -> Map TimeSig SWProf -> Map TimeSig SWProf
collectSWProf s m = foldr doSeg m s where

  doSeg :: SWProfSeg -> Map TimeSig SWProf -> Map TimeSig SWProf
  doSeg (TimedSeg ts p) m' = insertWith mergeSWProf (getEvent ts) p m'
 
  
-- | Transforms a quantised midi score into a set of meter profiles segmented
-- by the time signatures as prescribed in the midi file.
toSWProfSegs :: QMidiScore -> Either String [SWProfSeg]
toSWProfSegs m =    doIMA m 
                >>= fourBarFilter (ticksPerBeat . qMidiScore $ m)
                >>= return . map (toSWProf (ticksPerBeat . qMidiScore $ m))

-- | Sums all NSW profiles per bar for a meter section using the annotated
-- meter of that section
toSWProf :: TPB ->  SWMeterSeg -> SWProfSeg
toSWProf tb s = fmap (toNSWProfWithTS (getEvent . boundary $ s) tb) s

-- | Sums all NSW profiles per bar for a meter section using a specific meter
toNSWProfWithTS :: TimeSig ->TPB ->[Timed (Maybe ScoreEvent, SWeight)] -> SWProf
toNSWProfWithTS NoTimeSig _ _ = error "toNSWProfWithTS applied to NoTimeSig"
toNSWProfWithTS ts tb td = foldl' toProf (SWProf (1, empty)) td

  where toProf :: SWProf -> Timed (Maybe ScoreEvent, SWeight) -> SWProf
        toProf (SWProf (_b, m)) (Timed g (_se,w)) = 
          let (Bar br, bib, bt) = getBeatInBar ts tb g 
              m'                = insertWith (+) (bib,bt) w m 
              -- Every iteration we update the number of bars (lazily) 
              -- Hence, the last call to toProf will contain the final 
              -- number of bars correctly
          in  m' `seq` SWProf (NrOfBars br, m')

--------------------------------------------------------------------------------
-- Filtering Meter Segments
--------------------------------------------------------------------------------

-- Filters all segments that are at least 4 bars long. If the list does
-- not contain any segments longer then 4 bars Left is returned.
fourBarFilter :: TPB -> [SWMeterSeg] -> Either String [SWMeterSeg]
fourBarFilter tb = minBarLenFilter tb (NrOfBars 4)

minBarLenFilter :: TPB -> NrOfBars -> [TimedSeg TimeSig [Timed a]] 
                -> Either String [TimedSeg TimeSig [Timed a]]
minBarLenFilter tb bs s = 
  case filter (\x -> notEmpty x && getNrOfBars tb x > bs) s of
    [] -> Left ("minBarLenFilter: no segments longer then " ++ show bs)
    s' -> Right s'
  
emptySegFilter :: [SWMeterSeg] -> Either String [SWMeterSeg]
emptySegFilter s = case filter notEmpty s of
                     [] -> Left ("Song does not contain any notes")
                     r  -> Right r
  
getNrOfBars :: TPB -> TimedSeg TimeSig [Timed a] -> NrOfBars
getNrOfBars _  (TimedSeg _  []) = error "getNrOfBeats: empty List"
getNrOfBars tb (TimedSeg ts x ) = 
  let (br, _beat, _btrat) = getBeatInBar (getEvent ts) tb (onset . last $ x)
  in  NrOfBars (bar br)

notEmpty :: TimedSeg a [b] -> Bool
notEmpty (TimedSeg _ []) = False
notEmpty _               = True

-- TODO create a MPMidiScore for monophonic MidiScores
-- TODO create a QMPMidiScore for quantised monophonic MidiScores

--------------------------------------------------------------------------------
-- Performing the Inner Metrical Analysis
--------------------------------------------------------------------------------

doIMA :: QMidiScore -> Either String [SWMeterSeg]
doIMA qms = 
  let v    = toMonoVoice . qMidiScore $ qms
      md   = fromIntegral . minDur . qMidiScore $ qms
  in     return (toIMAOnset v)
     >>= addMaxPerCheck 
     >>= return . getSpectralWeight md
     -- >>= return . getMetricWeightGrid md
     -- First we calculate the IMA for the complete piece
     >>= return . matchScore v
     -- Then we segment the piece according to the annotated meters
     >>= return . segment (getTimeSig . qMidiScore $ qms)
                
--------------------------------------------------------------------------------
-- preprocessing
--------------------------------------------------------------------------------
                
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
matchScore :: Voice -> [(Int, SWeight)] -> [Timed (Maybe ScoreEvent, SWeight)]
matchScore v s = match (map (first Time) s) v where

  -- | matches a grid with spectral weights with the onsets that created the
  -- weights. 
  match :: [(Time, SWeight)] -> Voice -> [Timed (Maybe ScoreEvent, SWeight)]
  match [] []              = []
  match ((g, w):ws) []     =          addWeight w (Left g) : match ws []
  match ((g, w):ws) (t:ts) | g <  o = addWeight w (Left g) : match ws (t:ts)
                           | g == o = addWeight w (Right t): match ws ts
                           | otherwise = error "unmatched onset"
                               where o = onset t
  match _ _                = error "list of unequal lengths"             

  -- Normalises a spectral weight and combines it with a possible score event
  addWeight :: SWeight -> Either Time (Timed ScoreEvent) 
            -> Timed (Maybe ScoreEvent, SWeight)
  addWeight w e = either ((flip Timed) (Nothing, w)) f e
    
    -- where w'  = fromIntegral w / fromIntegral mx
    where -- f t = t {getEvent = (Just $ getEvent t, w')}
          f = fmap (\x -> (Just x, w))
          
--------------------------------------------------------------------------------
-- Printing the Inner Metrical Analysis
--------------------------------------------------------------------------------

printIMA :: QMidiScore -> IO ([SWProfSeg])
printIMA qm = mapM toNSWProfPrint . either error id . doIMA $ qm where
                
  toNSWProfPrint :: SWMeterSeg -> IO (SWProfSeg)
  toNSWProfPrint s = do let tb = ticksPerBeat . qMidiScore $ qm 
                        starMeter tb s >> return (toSWProf tb s)
                
          
-- Prints an Inner metrical analysis
starMeter :: TPB -> SWMeterSeg -> IO ()
starMeter tb (TimedSeg (Timed t ts) s) = 
  do putStrLn . printf ("%6d: ======================= " ++ show ts 
                         ++ " =======================" ) $ t
     mapM_ (toLine t ts) s where
                    
  -- prints one line e.g. "  2112:   2.2 -  1 /  2 1D : 397392 ***************"
  toLine :: Time -> TimeSig -> Timed (Maybe ScoreEvent, SWeight) -> IO ()
  toLine os x (Timed g (se,w)) = 
    let (br, bib, BeatRat r) = getBeatInBar x tb g
    in putStrLn (printf ("%6d: %3d.%1d - %2d / %2d" ++ showMSE se ++ ": %6d " ++ toStar w) 
                (g+os) br bib (numerator r) (denominator r) w)
                
  m = fromIntegral . maximum . map (snd . getEvent) $ s :: Double
  
  toStar :: SWeight -> String
  toStar x = stars (fromIntegral x / m)
                
  showMSE :: Maybe ScoreEvent -> String
  showMSE = maybe "    " (show . pitch) 
          