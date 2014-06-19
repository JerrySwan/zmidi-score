{-# OPTIONS_GHC -Wall                   #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveGeneric              #-}

-- | applying the Inner Metric Analysis to Midi files ('ZMidi.Score')
module ZMidi.IMA.Analyse ( SWMeterSeg
                         , IMAStore (..)
                         , imaTPB
                         , imaQBins
                         -- | * Inner Metrical Analysis
                         , doIMA -- TODO remove this export
                         , doIMApreprocess
                         , toIMAStore
                         -- | * Preprocessing
                         -- , emptySegFilter
                         , collectSWProf
                         -- , toSWProfSegs 
                         -- | * Utilities
                         , toNSWProfWithTS
                         , toSWProf
                         ) where

import ZMidi.IMA.NSWProf 
import ZMidi.Score
import ZMidi.Skyline.MelFind      ( mergeTracks )
import ZMidi.IMA.TimeSigSeg       ( TimedSeg (..), segment )

import IMA.InnerMetricalAnalysis hiding           ( Time(..) )
import qualified IMA.InnerMetricalAnalysis as IMA ( Time(..) )

import Data.List                   ( nubBy, foldl' )
import Data.Function               ( on )
import Data.Map.Strict             ( empty, Map, insertWith )
import Control.Arrow               ( first )

import Data.Binary                 ( Binary )
import GHC.Generics                ( Generic )

--------------------------------------------------------------------------------
-- Calculate Spectral Weight Profiles
--------------------------------------------------------------------------------

data IMAStore = IMAStore { imaFile      :: FilePath
                         , imaMidiScore :: QMidiScore
                         , swMeterSeg   :: [SWMeterSeg]
                         } deriving (Show, Eq, Generic)
instance Binary IMAStore 
  
imaTPB :: IMAStore -> TPB
imaTPB = ticksPerBeat . qMidiScore . imaMidiScore

imaQBins :: IMAStore -> QBins
imaQBins = toQBins . qShortestNote . imaMidiScore

  
-- A type synonym that captures all IMA information needed for meter estimation
type SWMeterSeg = TimedSeg TimeSig [Timed (Maybe ScoreEvent, SWeight)]

-- A type synonym for a Segment in which the IMA info has been compressed into
-- an Spectral Weight profile
type SWProfSeg = TimedSeg TimeSig SWProf

-- Performs an Inner Metric Analysis and stores the analysis and the 
-- ScoreEvents in a 'IMAStore'
toIMAStore :: FilePath -> Either String QMidiScore -> Either String IMAStore
toIMAStore f eqm = do qm  <- eqm
                      ima <- doIMApreprocess qm 
                      return $ IMAStore f qm ima

-- | Collects all profiles sorted by time signature in one map
collectSWProf :: [SWProfSeg] -> Map TimeSig SWProf -> Map TimeSig SWProf
collectSWProf s m = foldr doSeg m s where

  doSeg :: SWProfSeg -> Map TimeSig SWProf -> Map TimeSig SWProf
  doSeg (TimedSeg ts p) m' = insertWith mergeSWProf (getEvent ts) p m'

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

-- | Pre-processes a 'QMidiFile' and returns the IMA weights and score data
-- for segments that represent one time signature 
doIMApreprocess :: QMidiScore -> Either String [SWMeterSeg]
doIMApreprocess qm =   timeSigCheck qm
                   >>= doIMA
                   -- Filters all segments that are at least 4 bars long.
                   >>= minBarLenFilter tb (NrOfBars 4)
                   >>= emptySegFilter 
                     where tb = ticksPerBeat . qMidiScore $ qm

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

-- | Checks for a valid time signature
timeSigCheck :: QMidiScore -> Either String QMidiScore
timeSigCheck ms | hasTimeSigs (qMidiScore ms) = Right ms
                | otherwise = Left "Has no valid time signature" 

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
          

          