module FactExtractors::DuplicationCountExtractor
import Set;
import List;
import FactExtractors::ExtractorCommon;

data blockType = block(loc file, list[str] lines, int lineNumberStartsAt);

/*
  Extract the amount of duplicate code of at least 6 lines
*/
public int ExtractDuplicateCount(list[loc] allFiles)
{        
        list[blockType] lineBlocksAllTogether = ([]|it + GetAllPossibleLineBlocksOfSize6(f)| f <- allFiles);
        list[blockType] duplicateLineBlocks = toList(toSet(GetDuplicates(allFiles, lineBlocksAllTogether)));
        
        int countAllDublicateLines = (0| it + size(l.lines)| l <- duplicateLineBlocks);
        int countOverlappingDuplicateLines = GetOverlappingLinesCount(duplicateLineBlocks);

        return countAllDublicateLines - countOverlappingDuplicateLines;
}

list[blockType] GetAllPossibleLineBlocksOfSize6(loc file)
{
        list[str] allLines = GetCodeLines(file);        
        int amountOfAllLines = size(allLines);
        
        return amountOfAllLines >= 6 
                        ? [ block(file, allLines[i..i+6],i) | i <- [0..amountOfAllLines-6] ]
                        : [ block(file, allLines[..amountOfAllLines], 0) ];
}

list[blockType] GetDuplicates(list[loc] files, list[blockType] blockList)
{
        list[blockType] duplicates = [];
        
        /*duplicates += [ b, b2 | b <- blockList
                                        , b2 <- blockList
                                        , b.file != b2.file
                                        , b.lines == b2.lines ];
        
        duplicates += [ b, b2 | b <- blockList
                                        , b2 <- blockList
                                        , b.file == b2.file
                                        , b.lineNumberStartsAt != b2.lineNumberStartsAt
                                        , b.lines == b2.lines ];*/
        
        list[loc] otherFiles=files;
        for(f <- files)
        {
                otherFiles -= f;
                list[blockType] blocksInSameFile = [b | b <- blockList, b.file == f];
                duplicates += [ b,b2 | b <- blocksInSameFile
                                        , b2 <- blocksInSameFile
                                        , b.lineNumberStartsAt != b2.lineNumberStartsAt
                                        , b.lines == b2.lines ];
                
                for(of <- otherFiles)
                {
                        list[blockType] blocksInOtherFile = [b | b <- blockList, b.file == f];
                        duplicates += [ b, b2 | b <- blocksInSameFile
                                                , b2 <- blocksInOtherFile
                                                , b.lines == b2.lines ];
                }
        }
        
        return duplicates;
}

int GetOverlappingLinesCount(list[blockType] duplicateLineBlocks)
{        
        return (0 | it+5 |f <- duplicateLineBlocks
                                        ,f2 <- duplicateLineBlocks
                                        ,f.file == f2.file
                                        ,f.lineNumberStartsAt == (f2.lineNumberStartsAt - 1)
                                        ,f.lines[1..5] == f2.lines[..4]);
}