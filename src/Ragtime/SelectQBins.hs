{-# OPTIONS_GHC -Wall                   #-}
module Ragtime.SelectQBins ( selectQBins 
                           , filterByQBinStrength
                           -- , filterByQBinStrengthWith
                           -- , filterBin
                           , filterToList
                           , printMeterStats
                           , QBinSelection
                           ) where

import ZMidi.Score.Datatypes          ( TimeSig, Beat, BeatRat )
import Ragtime.NSWProf
import Data.List                      ( sort, sortBy )
import Data.Ord                       ( comparing, Down (..) )
import Data.Maybe                     ( fromJust )
import qualified Data.Map.Strict as M ( map, lookup )
import Data.Map.Strict                ( Map, toAscList, filterWithKey
                                      , mapWithKey, findWithDefault )
import Control.Arrow                  ( second )
                     
-- | A selection of the SWProf bins with the strongest weights                     
type QBinSelection = Map TimeSig [(Beat, BeatRat)]
                             
-- | creates a QBinSelection on a map of averaged NSWProfiles
selectQBins :: Int -> Map TimeSig NSWProf -> QBinSelection
selectQBins bs = M.map select where

  select :: NSWProf -> [(Beat, BeatRat)]
  select = -- sort . map fst -- and sort in regular order
           map fst . take bs          -- select 
         . sortBy (comparing (Down . snd)) . toAscList -- sort by weight
         . snd . nswprof                     -- ignore the nr of bars
         
-- Selects the bins marked in a 'QBinSelection' for a map of 'NSWProf's
filterByQBinStrengthWith :: QBinSelection -> Map TimeSig NSWProf -> Map TimeSig NSWProf
filterByQBinStrengthWith s m = mapWithKey (filterBin s) m where

filterBin :: QBinSelection -> TimeSig -> NSWProf -> NSWProf 
filterBin s ts = NSWProf . second (filterWithKey (\k _ -> k `elem` l)) . nswprof

  where l = fromJust $ M.lookup ts s 
  
-- Special case of 'filterByQBinStrengthWith' using the 12 most prominent bins
filterByQBinStrength :: Map TimeSig NSWProf -> Map TimeSig NSWProf
filterByQBinStrength m = filterByQBinStrengthWith (selectQBins 12 m) m

-- Given a selection, time signature selects the selected bins from a 'NSWProf'
-- and returns them in a list. If the selected bin is not present in the 
-- profile 0 is returned
filterToList :: QBinSelection -> TimeSig -> NSWProf -> [NSWeight]
filterToList s ts (NSWProf (_,p)) = reverse . sort -- sort by Weight
                                  . map fnd . fromJust . M.lookup ts $ s
  
  where fnd :: (Beat, BeatRat) -> NSWeight
        -- N.B. NSWeight is a log of the SWeight, we apply laplacian 
        -- smoothing with alpha is 1, log 1 = 0. See NSWProf.normSWProfByBar
        -- TODO unify the alpha parameter!
        fnd k = findWithDefault (NSWeight 0) k p
  
-- N.B. copied from 
-- Prints the average normalised inner metric analysis profiles to the user
printMeterStats :: Map TimeSig NSWProf -> IO ()
printMeterStats = mapM_ (putStrLn . showNSWProf) . toAscList 


