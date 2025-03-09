------------------------------ FLP first project --------------------------------------------------
------------------- Author: Veronika Nevarilova (xnevar00) ----------------------------------------
--------------------------------- Date: 03/25 -----------------------------------------------------
-------------------------------- File: Tree.hs ----------------------------------------------------
---------------------------------------------------------------------------------------------------

module Common (Tree(..), printTree, childIndent, splitByComma) where

-- Number of spaces used in every child node
childIndent :: Int
childIndent = 2

-- Data type for representing a decision tree
data Tree = Leaf String | Node Int Double (Tree) (Tree)
  deriving (Show)

-- Returns a String representing the tree in a readable way
printTree :: Tree -> String
printTree tree = init (treeToString 0 tree)

treeToString :: Int -> Tree -> String
treeToString indent (Leaf label) =
    replicate indent ' ' ++ "Leaf: " ++ label ++ "\n"
treeToString indent (Node index threshold left right) =
    replicate indent ' ' ++ "Node: " ++ show index ++ ", " ++ show threshold ++ "\n"
    ++ treeToString (indent + childIndent) left
    ++ treeToString (indent + childIndent) right
    
-- splits lines using commas, used for extracting features of records
splitByComma :: String -> [String]
splitByComma [] = []
splitByComma xs = result
    where
        first = takeWhile (/= ',') xs
        rest = drop 1 (dropWhile (/= ',') xs)
        result = first : splitByComma rest