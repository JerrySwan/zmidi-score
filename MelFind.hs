module MelFind where -- ( findMelody ) where

import ZMidiBasic

import Data.List          ( sortBy, groupBy )
import Data.Function      ( on )
import Data.Ord           ( comparing )
import Control.Arrow      ( (***), second )


--------------------------------------------------------------------------------
-- Melody Finding
--------------------------------------------------------------------------------

-- | Applies 'findMelodyQuant' to a 'MidiScore' but returns the score instead
-- of just the 'Voice'.
filterMelodyQuant :: ShortestNote -> MidiScore -> MidiScore
filterMelodyQuant q ms = ms {getVoices = [findMelodyQuant q ms]}

-- | Merges all 'Voices' and returns the melody using the skyline algorithm
-- with a lowerlimet at the middle C. The melody is quantised by
-- 'FourtyEighth' and the onverlapping notes are cut off. [more..?]
findMelodyQuant :: ShortestNote ->  MidiScore -> Voice
findMelodyQuant q = removeOverlap . head . getVoices 
                                  . sepHand (skyLineLowLim (Pitch (0,0))) 
                                  . quantise q . mergeTracks 

-- | Returns the melody 'Voice', if there the 'MidiScore' has exactly 2 voices
getMelody :: MidiScore -> Voice 
getMelody ms = case getVoices ms of
  [r,_l] -> r
  _   -> error "getMelody: Found a midifile with more or less than 2 tracks"

-- | Merges all tracks into one track
mergeTracks :: MidiScore -> MidiScore
mergeTracks ms = 
  ms {getVoices = [sortBy (comparing onset) . setChans 0 . concat . getVoices $ ms]} 
 
-- TODO: adapt channel number
-- | A hand separation function that takes a separation function and applies
-- this to a 'MidiScore'. sepHand throws an error the number of tracks is not 1
sepHand :: (Voice -> (Voice, Voice)) -> MidiScore -> MidiScore
sepHand f mf = case getVoices mf of
  [x] -> let (r,l) = f x in mf {getVoices = [r,l]}
  _   -> error "sepHand: more or less than 1 voice!"

-- | An implementation of the "skyline algorithm" that picks the highest note  
-- in a melody (high, low)
skyLine :: Voice -> (Voice, Voice)    
skyLine = skyLineLowLim (Pitch (-5,0))
    
-- | An implementation of the "skyline algorithm" that picks the highest note
-- in a melody (high, low), and has a lower limit. All notes below a 'Pitch' 
-- /x/ belong to the accompaniment
skyLineLowLim :: Pitch -> Voice -> (Voice, Voice)
skyLineLowLim p = (f 0 *** f 1) . unzip . map (pickHigh p) 
                                        . groupBy ((==) `on` onset)
  where f c = setChans c . concat

-- | Picks the highest notes and separates them from the rest (high,low)
pickHigh :: Pitch -> [Timed ScoreEvent] 
         -> ([Timed ScoreEvent],[Timed ScoreEvent])
pickHigh _ [ ] = error "pickHigh: empty list"
pickHigh p l | getPitch h >= p = ([h], t)
             | otherwise       = ([ ], l) 
                 where (h:t)   = reverse . sortBy (comparing getPitch) $ l 

       
data IntClass = Up | Down | OK | Drop deriving (Eq, Show)

dipDetect :: Interval -> Interval -> [Timed ScoreEvent] 
          -> [(Timed ScoreEvent, IntClass)]
dipDetect dwn up v = foldr mark [] . foldr classInter [] $ v where

  mark :: (Timed ScoreEvent, IntClass) -> [(Timed ScoreEvent , IntClass)]
         -> [(Timed ScoreEvent, IntClass)]
  mark x []    = [x]
  mark s (h:t) = case (snd s, snd h) of
    (Down, Up) -> s : second (const Drop) h : t
    _          -> s : h                     : t

  classInter :: Timed ScoreEvent -> [(Timed ScoreEvent , IntClass)]
           -> [(Timed ScoreEvent, IntClass)]
  classInter a []            = [(a, OK  )]
  classInter a l | i >= up   =  (a, Up  ) : l
                 | i <= dwn  =  (a, Down) : l
                 | otherwise =  (a, OK  ) : l
    where i = getInterval (getPitch a) (getPitch . fst . head $ l)

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

setChans :: Channel -> [Timed ScoreEvent] -> [Timed ScoreEvent]
setChans c = map (setChan c)

setChan :: Channel -> Timed ScoreEvent -> Timed ScoreEvent
setChan c tse = fmap f tse where f ne = ne {channel = c}

-- | Returns the number of different channels used in NoteEvents within a track
countChan :: Voice -> Int
countChan = length . groupBy ((==) `on` f) . sortBy (comparing f)
  where f = channel . getEvent

     