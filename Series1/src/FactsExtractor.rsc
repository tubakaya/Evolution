module FactsExtractor

import lang::java::jdt::m3::Core;
import util::FileSystem;
import List;
import IO;
import String;

/* Extracts only code lines*/
public int ExtractTotalLOC(loc project, str ext)
{
	list[loc] allFiles = GetAllFiles(project, ext);
	allLines = [readFileLines(f) | loc f <- allFiles];
	codeLines = [l | m <- allLines, l <- m
					, !isEmpty(trim(l))
					, !startsWith(trim(l),"/*")
					, !endsWith(trim(l),"*/")];
	return size(codeLines);	
}

/*Extract the total amount of Switch, If, For and While statements*/
public int ExtractTotalStatCount(loc project)
{}

/*Extract the amount of duplicate code of at least 6 lines*/
public int ExtractDuplicateCount(loc project, str ext)
{
	list[loc] allFiles = GetAllFiles(project, ext);
	map[loc, list[loc]] fileLines = [(f:readFileLines(f))| f <- allFiles];
	
	list[loc] visitedFiles;
	for(f <- allFiles)
	{
		visitedFiles +=f;
		list[loc] lines1 = readFileLines(f)[0];
		for( f2 <- (allFiles - visitedFiles))
		{
			list[loc] lines2 = readFileLines(f2)[0];
			list[loc] equalLines = [l1 | l1 <- lines1, l2 <- lines2, l1==l2];
			
			/*check the 6 lines starting with l1*/
			
		}
	}
	
	return 0;
}

public list[int] ExtractUnitSizes(loc project)
{
}

public int ExtractAssertCount(loc project)
{}

list[loc] GetAllFiles(loc project, str ext)
{
	return [f | /file(f) <- crawl(project), f.extension == ext];
}
