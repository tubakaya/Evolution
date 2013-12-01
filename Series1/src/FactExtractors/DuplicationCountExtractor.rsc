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
	map[block, loc] duplicates=();
    map[block, loc] otherBlocks = blockList;
    int i = 1;
    /* for debugging only */ int blockListSize = size(blockList);
    for(b <- blockList)
    { 
       otherBlocks = delete(otherBlocks, b);
       int j = 1;

       //TODO: I think this loop can be removed and use the lookup function
       //      of maps (lookup on key value).
       //      That's the whole idea of using maps, right?
       //      Because now it still performs O(n) instead of O(1).
       //
       //      Just see that the datastructure used is:
       //        map[<list[str] lines, int lineNumberStartsAt>, loc location]
       //
       //      I think this should be:
       //        map[list[str] lines, <int lineNumberStartsAt, loc location>]
       //      So the key of the map is not a tuple, but the 'extra data' is in
       //      the tuple. This makes coomparing and lookup in the map faster.
       //
       //      Next, just using a string as key makes it (possible) also faster
       //      for lookup (instead of using a list[str] as key).
       //      So the final datastructure would be like this:
       //        map[str lines, <int lineNumberStartsAt>, loc location>]
       //
       //      Just combine the list of strings of a block as 1 string (by
       //      using the toString() function on lists, or write your own
       //      function str join(list[str]) which concatenates all strings in
       //      the list).
       //
       //      After these changes a lookup can be done in O(1) like this:
       //        if (b in otherBlocks) { ... }
       //      or, if you know the ket exists, you can use
       //        value = otherBlocks[b]
       //      If the key not exists you get an error/exception.
       //      After 'value' contains the tuple with 'extra data' like
       //      lineNumberStartsAt and location  
       /*
               debug("checking block <i> / <blockListSize>");
               if (b in otherBlocks) {
                 debug("\tDUPLICATE FOUND");
               }
       */
       
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
	map[list[block], loc] blocksPerFile=();
	
	list[loc] files= toList(toSet([duplicateBlocks[b] | b <- duplicateBlocks]));
	for(f <- files)
	{
		list[block] blocks = [b | b <- duplicateBlocks, duplicateBlocks[b] == f];
		blocksPerFile +=(blocks:f);
	}										   
												
	int overlappingLines = 0;
	for(bs <- blocksPerFile)
	{
		overlappingLines += (0 | it+ b.lineNumberStartsAt + 6 - b2.lineNumberStartsAt| b <- bs
										, b2 <- bs
										, b2.lineNumberStartsAt > b.lineNumberStartsAt
										, b2.lineNumberStartsAt < b.lineNumberStartsAt + 6 );
	}
	
	return totalLines - overlappingLines;
}