------------------------------ FLP first project --------------------------------------------------
------------------- Author: Veronika Nevarilova (xnevar00) ----------------------------------------
--------------------------------- Date: 03/25 -----------------------------------------------------
------------------------------- File: task1.hs ----------------------------------------------------
---------------------------------------------------------------------------------------------------

module Task1 (parseTree, classify, prepareRecords) where

import Data.Char (isDigit, isSpace)
import Data.List (isPrefixOf, tails, find)
import Common (Tree(..), childIndent, splitByComma)

-- function for getting word before the ':' and returns it along with the rest
getNextWord :: String -> (String, String)
getNextWord line = (takeWhile (/= ':') line, drop 2 (dropWhile (/= ':') line))

-- extract the index and threshold of node
getIndexAndThreshold :: String -> (Int, Double)
getIndexAndThreshold line = (index, threshold)
    where
        index = read (takeWhile isDigit line)
        rest = dropWhile (/= ',') line
        thresholdStr = takeWhile (\c -> isDigit c || c == '.' || c == '-' || c == 'e') (dropWhile isSpace (tail rest))
        threshold = read thresholdStr

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
                            Nothing -> ""

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
    _ -> Leaf "Unknown"

-- base function to classify input record based on its features
-- records with equal values as the node threshold are directed to the left subtree
classify :: Tree -> [Double] -> String
classify (Leaf label) _ = label
classify (Node index threshold left right) values
    | values !! index <= threshold = classify left values
    | otherwise                   = classify right values

-- parses the input records to be classified
prepareRecords :: String -> [[Double]]
prepareRecords text = result
    where
        items = lines text
        result = map (\line -> map read (splitByComma line)) items