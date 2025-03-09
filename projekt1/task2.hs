------------------------------ FLP first project --------------------------------------------------
------------------- Author: Veronika Nevarilova (xnevar00) ----------------------------------------
--------------------------------- Date: 03/25 -----------------------------------------------------
------------------------------- File: task2.hs ----------------------------------------------------
---------------------------------------------------------------------------------------------------

module Task2 (parseTrainingSamples, createTree) where

import Data.List (sortBy, group, sort, nub, partition, minimumBy)
import Data.Ord (comparing)
import Common (Tree(..), splitByComma)

data TrainingSample = TrainingSample String [Double]
  deriving (Show)

-- parses one line of file content to one training sample
parseLine :: String -> TrainingSample
parseLine line = TrainingSample classLabel features
    where
        rawFeatures = splitByComma line
        features = map read (init rawFeatures)  -- take all besides the last one (class label)
        classLabel = last rawFeatures           -- the last one = class label

-- parses whole input str (file content) to an array of samples
parseTrainingSamples :: String -> [TrainingSample]
parseTrainingSamples text = map parseLine (lines text)

-- sorts samples by ascending order of a certain feature
sortSamplesByFeature :: Int -> [TrainingSample] -> [TrainingSample]
sortSamplesByFeature index samples = sortBy (comparing (\(TrainingSample _ features) -> features !! index)) samples

-- gini of one part 
giniValueOfOnePart :: [TrainingSample] -> Double
giniValueOfOnePart samples = result
    where 
        total = fromIntegral (length samples)
        uniqueClasses = nub [label | TrainingSample label _ <- samples]
        classCounts = map (\c -> length (filter (\(TrainingSample label _) -> label == c) samples)) uniqueClasses
        result = 1.0 - sum [(fromIntegral count / total) ** 2 | count <- classCounts]

-- computes the whole gini value of situation where the samples would be split according to the threshold of certain index
-- gini = size(group1)/total_size * gini(group1) + size(group2)/total_size * gini(group2)
computeSplitGini :: Int -> Double -> [TrainingSample] -> Double
computeSplitGini index threshold samples = (fromIntegral (length left) / fromIntegral totalSize) * leftGini + (fromIntegral (length right) / fromIntegral totalSize) * rightGini
    where
        (left, right) = partition (\(TrainingSample _ features) -> features !! index <= threshold) samples -- divide into two sets according to threshold
        leftGini = giniValueOfOnePart left
        rightGini = giniValueOfOnePart right
        totalSize = length samples

-- helper function for computing mean value of two doubles, used in 'computeThresholdsAndGiniValues'
mean :: Double -> Double -> Double
mean a b = (a + b) / 2

-- computes the possible thresholds of the index and their gini values
-- the thresholds are always between two real values of the feature
-- e.g. values (1.0, 2.0, 4.0) -> thresholds (1.5, 3.0)
computeThresholdsAndGiniValues :: Int -> [TrainingSample] -> [(Double, Double)]
computeThresholdsAndGiniValues index samples = map computeGiniForThreshold thresholds
    where
        sortedSamples = sortSamplesByFeature index samples
        featureValues = [features !! index | TrainingSample _ features <- sortedSamples]
        thresholds = nub (zipWith mean featureValues (tail featureValues))
        computeGiniForThreshold thr = (thr, computeSplitGini index thr samples)

-- returns the (threshold, gini value) of the best choice for split, based on the lowest gini value
getBestThresholdForFeature :: Int -> [TrainingSample] -> (Double, Double)
getBestThresholdForFeature index samples = minimumBy (comparing snd) thresholdsAndGinis
    where
        thresholdsAndGinis = computeThresholdsAndGiniValues index samples

-- is True when all the training samples share the same class
onlyOneClass :: [TrainingSample] -> Bool
onlyOneClass samples = all (\(TrainingSample label _) -> label == firstSampleClassLabel) samples
  where firstSampleClassLabel = getClassLabel (head samples)

-- helper function for getting the class label of one training sample
getClassLabel :: TrainingSample -> String
getClassLabel (TrainingSample label _) = label

-- gets the number of features to compute thresholds and gini values for
getFeaturesSize :: TrainingSample -> Int
getFeaturesSize (TrainingSample _ features) = length (features)

-- gets the best threshold (index, threshold, gini) for one feature
computeBestSplitForOneFeature :: Int -> [TrainingSample] -> (Int, Double, Double)
computeBestSplitForOneFeature i samples = (i, threshold, gini)
    where 
        (threshold, gini) = getBestThresholdForFeature i samples 

-- gets the best threshold (index, threshold, gini) for each feature
computeBestSplitForAllFeatures :: [TrainingSample] -> [(Int, Double, Double)]
computeBestSplitForAllFeatures samples =
    map (\i -> computeBestSplitForOneFeature i samples) [0 .. getFeaturesSize (head samples) - 1]


-- base function that creates the tree from the parsed training samples
createTree :: [TrainingSample] -> Tree
createTree samples
    | onlyOneClass samples = Leaf (getClassLabel (head samples))
    | otherwise            = Node bestFeature bestThreshold leftSubtree rightSubtree
        where
            (bestFeature, bestThreshold, _) = minimumBy (comparing (\(_, _, gini) -> gini)) (computeBestSplitForAllFeatures samples)

            -- split the samples by the selected threshold
            (leftSamples, rightSamples) = partition (\(TrainingSample _ features) -> features !! bestFeature <= bestThreshold) samples

            -- recursive call for both subsets
            leftSubtree = createTree leftSamples
            rightSubtree = createTree rightSamples