import System.Environment (getArgs)
import Data.Char (isDigit, isSpace)
import Data.List (isPrefixOf, tails, find, sortBy, group, sort, nub, partition, minimumBy)
import Data.List (sortBy)
import Data.Ord (comparing)

-- number of spaces used in every next child of some node
childIndent = 2

-- data type for representing a decision tree
data Tree = Leaf String | Node Int Double (Tree) (Tree)
  deriving (Show)

-- returns a String representing the tree in a readable way
printTree :: Tree -> String
printTree tree = reverse ( drop 1 ( reverse (treeToString 0 tree)))

treeToString :: Int -> Tree -> String
treeToString indent (Leaf label) =
    replicate indent ' ' ++ "Leaf: " ++ label ++ "\n"
treeToString indent (Node index threshold left right) =
    replicate indent ' ' ++ "Node: " ++ show index ++ ", " ++ show threshold ++ "\n"
    ++ treeToString (indent + childIndent) left
    ++ treeToString (indent + childIndent) right

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- TASK 1

-- function for getting word before the ':' and returns it along with the rest
getNextWord :: String -> (String, String)
getNextWord line = (takeWhile (/= ':') line, drop 2 (dropWhile (/= ':') line))

-- extract the index and threshold of node
getIndexAndThreshold :: String -> (Int, Double)
getIndexAndThreshold line = (index, threshold)
    where
        index = read (takeWhile isDigit line)
        threshold = read (takeWhile (\c -> isDigit c || c == '.') (tail (drop 1 (dropWhile (/= ',') line))))

-- shifts the string to the next new line
goToNewLine:: String -> String
goToNewLine line = drop 1 (dropWhile (/= '\n') line)

-- extracts two strings representing children based on the required depth
getSubtrees :: String -> Int -> (String, String)
getSubtrees text depth =
    (take (length text - length secondSubtree + 1) text, drop 1 secondSubtree)
    where
        -- every line starts either with word Leaf or Node, no need to check for other letters
        leafPattern = "\n" ++ replicate depth ' ' ++ "L"
        nodePattern = "\n" ++ replicate depth ' ' ++ "N"

        hasPattern s = leafPattern `isPrefixOf` s || nodePattern `isPrefixOf` s
        suffixes = tails text

        secondSubtree = case find hasPattern suffixes of
                            Just match -> match

-- base function that creates a tree from the input string
parseTree :: String -> Int -> Tree
parseTree line depth = case getNextWord (dropWhile isSpace line) of
    ("Leaf", rest) -> Leaf (takeWhile (/= '\n') rest)
    ("Node", rest) ->
        -- recursive call for children
        Node index threshold (parseTree leftSubtree newIndent) (parseTree rightSubtree newIndent)
        where
            (index, threshold) = getIndexAndThreshold rest
            newLine = goToNewLine rest
            newIndent = depth + childIndent
            (leftSubtree, rightSubtree) = getSubtrees newLine newIndent

-- base function to classify input record based on its features
-- records with equal values as the node threshold are directed to the left subtree
classify :: Tree -> [Double] -> String
classify (Leaf label) _ = label
classify (Node index threshold left right) values
    | values !! index <= threshold = classify left values
    | otherwise                   = classify right values

-- splits lines using commas, used for extracting features of records
splitByComma :: String -> [String]
splitByComma [] = []
splitByComma xs = result
    where
        first = takeWhile (/= ',') xs
        rest = drop 1 (dropWhile (/= ',') xs)
        result = first : splitByComma rest

-- parses the input records to be classified
prepareRecords :: String -> [[Double]]
prepareRecords text = result
    where
        items = lines text
        result = map (\line -> map read (splitByComma line)) items

-- END OF TASK 1
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- TASK 2
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

-- END OF TASK 2
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

main = do
    args <- getArgs
    case args of
        ("-1":treeFile:dataFile:_) -> do
            treeContents <- readFile treeFile
            dataContents <- readFile dataFile
            let tree = parseTree treeContents 0
            let itemsToClassify = prepareRecords dataContents
            let results = map (classify tree) itemsToClassify
            mapM_ putStrLn results
        ("-2":trainingDataFile:_) -> do
            trainingDataContents <- readFile trainingDataFile
            let samples = parseTrainingSamples trainingDataContents
            let resultTree = createTree samples
            putStrLn (printTree resultTree)
        _ -> putStrLn "Usage:\nflp-fun -1 <soubor obsahujici strom> <soubor obsahujici nove data> \nflp-fun -2 <soubor obsahujici trenovaci data>"