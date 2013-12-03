@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module FactExtractors::ClonesExtractor

import FactExtractors::ExtractorCommon;
import Set;
import List;
import Utils;
import IO;

data line = line(str val, int lineIndex, int fileIndex);

public int ExtractDuplicateCount(list[loc] allFiles)
{
	debug("\tstarting extract duplicate count");
	list[line] allLines = [];
	int fileIndex = 1;
	for(f <- allFiles)
	{
	 	int lineIndex = 1;
	 	for(l <- GetCodeLines(f))
	 	{
	 		allLines += line(l,lineIndex,fileIndex);
	 		lineIndex +=1;
	 	}
	 	fileIndex +=1;
	}
	
	debug("\tamount of allLines <size(allLines)>");
	list[str] onlyLineValues = [l.val | l <- allLines]; 
	list[str] distinctLineValues = dup(onlyLineValues);
	debug("\tamount of distinctLineValues <size(distinctLineValues)>");
	list[str] duplicateLineValues = onlyLineValues - distinctLineValues;
	debug("\tamount of duplicateLineValues <size(duplicateLineValues)>");
	list[line] duplicateLines = [l|l <- allLines, l.val in duplicateLineValues];
	debug("\tamount of duplicateLines <size(duplicateLines)>");
	
	int result = 0;
	set[int] distinctFileIndexes= {l.fileIndex|l<-duplicateLines};
	int filesCount = size(distinctFileIndexes);
	debug("\tamount of files <filesCount>");
	int processedFileNumber = 1;
	for(fi <- distinctFileIndexes)
	{
		debug("\tfile <processedFileNumber> / <filesCount>");
		processedFileNumber += 1;
		
		list[int] lineIndexesInFile = sort({l.lineIndex| l<-duplicateLines, l.fileIndex == fi});
		int lineCount = size(lineIndexesInFile);
		if(lineCount > 5)
		{
			int maxCounterVal = lineCount -1;
			int counter = 0;
			
			while(maxCounterVal >= counter+1)
			{
				int duplicatesCount = 0;
				
				int index = lineIndexesInFile[counter];
				counter +=1;
				index+=1;	
				while(maxCounterVal >= counter && index == lineIndexesInFile[counter])
				{
					counter +=1;
					index+=1;	
					duplicatesCount+=1;			
				}
						
				if(duplicatesCount > 5)
				{
					result += duplicatesCount;
				}					
			}
			
		}
	}
	return result;
}