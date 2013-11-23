module FactExtractors::TotalLOCExtractor

import FactExtractors::ExtractorCommon;

import List;

/*
  Extracts only code lines
*/
public int ExtractTotalLOC(loc project, str ext)
{
	list[loc] allFiles = GetAllFiles(project, ext);
	list[list[str]] codeLines = [GetCodeLines(f) | f <- allFiles ];
	
	int counter = 0;
	for( i <- [0..size(codeLines)])
	{
		counter += size(codeLines[i]);
	}
	
	return counter;
}