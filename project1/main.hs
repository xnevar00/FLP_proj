------------------------------ FLP first project --------------------------------------------------
------------------- Author: Veronika Nevarilova (xnevar00) ----------------------------------------
--------------------------------- Date: 03/25 -----------------------------------------------------
-------------------------------- File: main.hs ----------------------------------------------------
---------------------------------------------------------------------------------------------------

import System.Environment (getArgs)
import Common (printTree)
import Task1 (parseTree, classify, prepareRecords)
import Task2 (parseTrainingSamples, createTree)

main :: IO ()
main = do
    args <- getArgs
    case args of
        ("-1":treeFile:dataFile:_) -> do
            treeContents <- readFile treeFile
            dataContents <- readFile dataFile
            let tree = parseTree treeContents 0
            let records = prepareRecords dataContents
            mapM_ (putStrLn . classify tree) records
        ("-2":trainingDataFile:_) -> do
            trainingDataContents <- readFile trainingDataFile
            let samples = parseTrainingSamples trainingDataContents
            putStrLn (printTree (createTree samples))
        _ -> putStrLn "Usage: flp-fun -1 <tree file> <data file> \nflp-fun -2 <training data file>"
