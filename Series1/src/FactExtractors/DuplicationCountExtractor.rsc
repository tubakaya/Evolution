@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module FactExtractors::DuplicationCountExtractor
import Set;
import List;
import FactExtractors::ExtractorCommon;
import Utils;
import Map;

data block = block(list[str] lines, int lineNumberStartsAt);

/*
  Extract the amount of duplicate code of at least 6 lines
*/
public int ExtractDuplicateCount(list[loc] allFiles)
{        
    map[block, loc] blocks = (b:f | f <- allFiles
    								,b <- GetAllPossibleLineBlocksOfSize6(f));

    map[block, loc] duplicateBlocks = GetDuplicates(blocks);
	int duplicateLinesCount = GetDuplicateLinesCount(duplicateBlocks);
    return duplicateLinesCount;
}

list[block] GetAllPossibleLineBlocksOfSize6(loc file)
{

    list[str] allLines = GetCodeLines(file);        
    int amountOfAllLines = size(allLines);
      
    list[block] blocks = amountOfAllLines >= 6 
                        ? [ block(allLines[i..i+6], i) | i <- [0..amountOfAllLines-6] ]
                        : [ block(allLines[..amountOfAllLines], 0) ];
                        
    return blocks;
}

map[block, loc] GetDuplicates(map[block, loc] blockList)
{
    map[block, loc] otherBlocks = blockList;
    int i = 1;
    for(b <- blockList)
    { 
       otherBlocks = delete(otherBlocks, b);
       int j = 1;
       for(ob <- otherBlocks)
       {
       	   debug("\tchecking method <i> / <j>"); 
           
           if(b.lines == ob.lines)
           {
           		duplicates += (b:blockList[b]);
           		duplicates += (ob:otherBlocks[ob]);
           }
             
           j += 1; 
       }  
       debug("\tamount of duplicates <size(duplicates)>");
       i+=1;     
    }
        
    return duplicates;
}

int GetDuplicateLinesCount(map[block, loc] duplicateBlocks)
{
	int totalLines = size(duplicateBlocks) * 6;
		
	map[loc, block] reverseDuplicateBlocks = (f:b| b <- duplicateBlocks, f <- duplicateBlocks[b]);
	
	int overlappingLines = 0;
	for(f <- reverseDuplicateBlocks)
	{
		list[block] blocksInFile= [b|b <-reverseDuplicateBlocks[f]];
		overlappingLines += (0 | it+ b.lineNumberStartsAt + 6 - b2.lineNumberStartsAt| b <- blocksInFile
										, b2 <- blocksInFile
										, b2.lineNumberStartsAt > b.lineNumberStartsAt
										, b2.lineNumberStartsAt < b.lineNumberStartsAt + 6 );
	}
	
	return totalLines - overlappingLines;
}