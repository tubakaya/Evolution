module FactExtractors::DuplicationCountExtractor
import Set;
import List;
import FactExtractors::ExtractorCommon;

data blockType = block(loc file, list[str] lines, int lineNumberStartsAt);

/*
  Extract the amount of duplicate code of at least 6 lines
*/
public int ExtractDuplicateCount(loc project, str ext)
{	
	list[loc] allFiles = GetAllFiles(project, ext);
	list[blockType] lineBlocksAllTogether = [];
	
	for(f <- allFiles)
	{
		lineBlocksAllTogether += GetAllPossibleLineBlocksOfSize6(f);
	}

	list[blockType] duplicateLineBlocks = GetDuplicates(lineBlocksAllTogether);
	
	int countAllDublicateLines = (0| it + size(l.lines)| l <- duplicateLineBlocks);
	int countOverlappingDuplicateLines = (0| it + 5| 
											f <- duplicateLineBlocks
											, f2 <- duplicateLineBlocks
											, f.file == f2.file
											, f.lines[1..5] == f2.lines[..4]);
	return countAllDublicateLines - countOverlappingDuplicateLines;
}

list[blockType] GetAllPossibleLineBlocksOfSize6(loc file)
{
	list[str] allLines = GetCodeLines(file);	
	int amountOfAllLines = size(allLines);
	
	return amountOfAllLines >= 6 
			? [ block(file, allLines[i..i+6],i) | i <- [0..amountOfAllLines-6] ]
			: [ block(file, allLines[..amountOfAllLines],0) ];
}

list[blockType] GetDuplicates(list[blockType] blockList)
{
	return [ b, b2 | b <- blockList
					, b2 <- blockList
					, b.file == b2.file
					, b.lineNumberStartsAt != b2.lineNumberStartsAt
					, b.lines == b2.lines ];
}