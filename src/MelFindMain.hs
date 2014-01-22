module Main where

import System.Environment ( getArgs )
import Data.List          ( intercalate, genericLength, intersectBy )

import ZMidi.IO.Common    ( readMidiFile, readMidiScore, mapDir
                          , mapDir_, logDuplicates, writeMidiScore
                          , removeTrackLabels )
import ZMidi.Core         ( writeMidi, MidiFile (..) )
import ZMidi.Skyline.MelFind
import ZMidi.Score.Datatypes

main :: IO ()
main = do arg <- getArgs
          case arg of
            ["-s", d] -> do putStrLn ("filepath\tmin 1\tmax 1\tmin 2\tmax 2")
                            mapDir_ showMidiStats d
            ["-d", d] -> do putStrLn ("filepath\tprecision\trecall\tf-measure")
                            rs <- mapDir evalHandSep d
                            putStrLn ("averages\t" ++ (show . averagePRF $ rs))
            ["-b", d] -> mapDir_ (quantiseAndMelFind FourtyEighth) d
            ["-f", f] -> createSepHandMidiFile f
            ["-r", f] -> reverse2Tracks f
            ["-q", f] ->   readMidiScore f >>= writeMidi (f ++ ".quant.mid") 
                         . midiScoreToMidiFile . quantise FourtyEighth
            ["-l", d] -> logDuplicates d
            ["-n", f] -> removeTrackLabels f
            ["-x", f] -> melodySkyline f 
            ["-m", f] -> filterMelMidiFile FourtyEighth f 
            ["-t", f] -> test FourtyEighth f
            
            _  -> putStrLn ("usage: -f <filename>  do melody finding\n"++
                            "   OR  -r <filename>  reverse track order\n"++
                            "   OR  -q <filename>  quantise midi track\n"++
                            "   OR  -n <filename>  remove track labels\n"++
                            "   OR  -m <filename>  remove all but the extracted melody\n"++
                            "   OR  -x <filename>  skyline filtering in a melody\n"++
                            "   OR  -d <directory> evaluate melody finding\n" ++ 
                            "   OR  -s <directory> show some statistics\n" ++
                            "   OR  -b <directory> batch melodyfinding and quantisation\n" ++
                            "   OR  -t <filename>  for testing\n" 
                            )

test :: ShortestNote -> FilePath -> IO ()
test q f = do mf <- readMidiScore f >>= return . filterMelodyQuant q 
              print . dipDetect (-9) 9 . head . getVoices $ mf
            

                            
-- For checking the removal of chords in the melody track
melodySkyline :: FilePath -> IO ()
melodySkyline f = do mf <- readMidiScore f                             
                     let (mel : rest) = getVoices mf
                         (mel', remv) = skyLine mel
                     print remv
                     writeMidiScore mf {getVoices = (mel':rest)} (f ++ ".test.mid") 
                            
-- We do an automatic
evalHandSep :: FilePath -> IO (PrecisionRecallFMeasure)
evalHandSep f = do putStr (show f ++ "\t")
                   m <- readMidiScore f
                   let r = melodyRetrieval skyLineLLDipDetect m 
                   putStrLn (show r ++ '\t' : (show . hasExpectedHandOrder $ m)
                                    ++ '\t' : (show . hasTwoDupTracks $ m)
                                    ++ '\t' : (intercalate "\t" 
                                        . map (show . countChan) $ getVoices m))
                   return r

quantiseAndMelFind ::  ShortestNote -> FilePath -> IO ()
quantiseAndMelFind q  f = do m <- readMidiScore f
                             writeMidiScore (quantise q m) (f ++ ".quantise.mid")
                             putStrLn ("written: " ++ f ++ ".quantise.mid")
                             writeMidiScore (filterMelodyQuant q m) (f ++ ".melody.dip.mid")
                             putStrLn ("written: " ++ f ++ ".melody.dip.mid")
                   
-- | 
filterMelMidiFile :: ShortestNote -> FilePath -> IO ()
filterMelMidiFile q f = readMidiScore f >>=  writeMidi (f ++ ".melody.mid") 
                      . midiScoreToMidiFile . filterMelodyQuant q
                   
                   
-- | Takes a 'MidiFile' merges the tracks separates the hands again and 
-- saves the result to a file
createSepHandMidiFile :: FilePath -> IO ()
createSepHandMidiFile f = readMidiScore f >>=  writeMidi (f ++ ".handsep.mid") 
                        . midiScoreToMidiFile 
                        . sepHand (skyLineLowLim (Pitch (0,0))) 
                        . mergeTracks 
                        -- . quantise FourtyEighth 

-- | Prints some statistics of the 'MidiScore' to the console
showMidiStats :: FilePath -> IO ()
showMidiStats fp = do ms <- readMidiScore fp
                      putStr (fp ++ "\t")
                      putStrLn . intercalate "\t"  . map showVoiceStats 
                               . getVoices $ ms where

  showVoiceStats :: Voice -> String
  showVoiceStats v = let (mn,mx) = voiceStats v in show mn ++ '\t' : show mx

voiceStats :: Voice -> (Pitch,Pitch)
voiceStats v = let ps = map getPitch v 
               in (minimum ps, maximum ps)  

-- | Checkes if the both the lowest and the highest note in the melody were 
-- higher than the lowest and highest note in the accompaniment.
hasExpectedHandOrder :: MidiScore -> Bool
hasExpectedHandOrder ms = case getVoices ms of
  [r,l] -> let (minR, maxR) = voiceStats r
               (minL, maxL) = voiceStats l
           in  minR > minL && maxR > maxL
  _     -> error ("hasExpectedHandOrder: Found a midifile with more or " ++
                  "less than 2 tracks")

-- | Returns true if the two tracks in the MidiScore are duplicates
hasTwoDupTracks :: MidiScore -> Bool
hasTwoDupTracks ms = case getVoices ms of
  [r,l] -> r == l
  _     -> error ("hasExpectedHandOrder: Found a midifile with more or " ++
                  "less than 2 tracks")

--------------------------------------------------------------------------------
-- Evaluation
--------------------------------------------------------------------------------

-- | Does the melody retrieval based on a separation function. 
-- N.B. in the evaluation we ignore chords in the groundtruth melody track,
-- and only the highest note is taken into consideration.
melodyRetrieval :: (Voice -> (Voice, Voice)) -> MidiScore 
                  -> PrecisionRecallFMeasure
melodyRetrieval f ms = 
  noteRetrieval (fst . skyLine . getMelody $ ms) 
                (getMelody . sepHand f . mergeTracks $ ms)

-- | Given a groundtruth 'Voice' (first argument) and a test 'Voice' calculates
-- the recall, precision and F-meaures
noteRetrieval :: Voice -> Voice -> PrecisionRecallFMeasure
noteRetrieval gt test = precRecF eqf gt test where
  
  eqf :: Timed ScoreEvent -> Timed ScoreEvent -> Bool
  eqf (Timed onA datA) (Timed onB datB) =  onA           == onB 
                                        && pitch    datA == pitch datB
                                        && velocity datA == velocity datB
                                        && duration datA == duration datB

-- | calculates the the triplet of Precision, Recall and F-Measure given
-- a list of segmentable groundtruth items and test items.
precRecF :: (a -> a -> Bool) -> [a] -> [a] -> PrecisionRecallFMeasure
precRecF eqf gt test = 
  let inters    = genericLength $ intersectBy eqf gt test
      precision = inters / genericLength test
      recall    = inters / genericLength gt
      fMeasure  = (2 * precision * recall) / (precision + recall)
  in precision `seq` recall `seq` fMeasure `seq` PRF precision recall fMeasure

-- | Datatype for storing the triplet of Precision, Recall and F-Measure
data PrecisionRecallFMeasure = PRF Double Double Double 

instance Show PrecisionRecallFMeasure where
  show (PRF p r f) = intercalate "\t" . map show $ [p,r,f]
 
-- | Calculates the average of a list of 'PrecisionRecallFMeasure' triplets
averagePRF :: [PrecisionRecallFMeasure] -> PrecisionRecallFMeasure
averagePRF prfs = prfDiv (genericLength prfs) . foldr1 step $ prfs where
                
      step (PRF pa ra fa) (PRF pb rb fb) = PRF (pa + pb) (ra + rb) (fa + fb)

      prfDiv :: Double -> PrecisionRecallFMeasure -> PrecisionRecallFMeasure 
      prfDiv len (PRF p r f) = PRF (p/len)   (r/len)   (f/len)
      
--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------
  
-- | Reverses the order of the first two tracks in a 'MidiFile'
reverse2Tracks :: FilePath -> IO ()
reverse2Tracks f = 
  do mf <- readMidiFile f
     -- It is customary to use a first track for storing meta data.
     -- Also, sometimes additional information is stored in some trailing
     -- tracks.
     let (empty, t1 : t2 : rest) = span (not . hasNotes) . mf_tracks $ mf
     writeMidi (f ++ ".rev2trk.mid") mf {mf_tracks = empty ++ (t2 : t1 : rest)}
                  