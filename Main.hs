module Main where

import ZMidi.Core (MidiFile, readMidi, printMidi, canonical)
import ZMidiBasic

import Control.Monad (filterM)
import System.Directory ( getDirectoryContents, canonicalizePath
                        , doesDirectoryExist)
import System.IO (stderr, hPutStr)
import System.FilePath 
import System.Environment (getArgs)

-- import Debug.Trace (traceShow)

main :: IO ()
main = do arg <- getArgs
          case arg of
            ["-d", d] -> do putStrLn ("filepath\tTime Signatures\tKeys\t" ++
                                "Nr. Voices\tQuantised or not?\tNr. Notes")
                            mapDirInDir (mapDir showMidiStats) d
            ["-f", f] -> readMidiFile f
            _         -> putStrLn "usage:  <filename> "


readMidiFile :: FilePath -> IO ()
readMidiFile f = do mf <- readMidi f
                    case mf of
                      Left  err -> putStrLn (f ++ '\t' : show err)
                      Right mid -> do let -- cmid = canonical mid
                                          ms   = midiFileToMidiScore mid 
                                          tm   = buildTickMap . getVoices $ ms
                                      printMidi mid
                                      print tm
                                      print . isQuantisedVerb $ tm
                                      putStrLn . showMidiScore $ ms
                                   -- print . midiFileToMidiScore $ cmid 

                                   
showMidiStats :: FilePath -> IO ()
showMidiStats fp = do mf <- readMidi fp
                      case mf of
                        Left  err -> putStrLn (fp ++ '\t' : show err)
                        Right mid -> 
                          do let m = midiFileToMidiScore mid
                                 tm = buildTickMap . getVoices $ m
                                 q  = if isQuantised tm then "Quantised" else "No"
                             putStrLn (fp ++ '\t' : show (getTimeSig m) 
                                ++ '\t' : show (getKey m)
                                ++ '\t' : (show . length . getVoices $ m) 
                                ++ '\t' : q ++ '\t' : (show . nrOfNotes $ m))


mapDirInDir :: (FilePath -> IO ()) -> FilePath ->  IO ()
mapDirInDir f fp = do fs  <- getDirectoryContents fp 
                              >>= return . filter (\x -> x /= "." && x /= "..") 
                      cfp <- canonicalizePath fp
                      filterM doesDirectoryExist (fmap (cfp </>) fs) >>= mapM_ f 
                                        
mapDir :: (FilePath -> IO ()) ->  FilePath -> IO ()
mapDir f fp = do fs <- getDirectoryContents fp >>= 
                   return . filter (\x -> x /= "." && x /= "..") 
                 cin <- canonicalizePath fp
                 putErrStrLn cin
                 mapM_ (f . (cin </>)) fs

putErrStrLn :: String -> IO ()
putErrStrLn s = do hPutStr stderr s
                   hPutStr stderr "\n"