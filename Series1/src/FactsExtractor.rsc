module FactsExtractor
import util::FileSystem;
import List;
import IO;
import String;

import lang::java::jdt::m3::Core;

/* Extracts only code lines*/
public int ExtractTotalLOC(loc project, str ext)
{
	list[loc] allFiles = [f | /file(f) <- crawl(project), f.extension == ext];	
	allLines = [readFileLines(f) | loc f <- allFiles];
	codeLines = [l |l <- allLines[0]
					, !isEmpty(trim(l))
					, !startsWith(trim(l),"/*")
					, !endsWith(trim(l),"*/")];
	return size(codeLines);	
}

/*Extract the total amount of Switch, If, For and While statements*/
public int ExtractTotalStatCount(loc project)
{}

/*Extract the amount of dublicate code of at least 6 lines*/
public int ExtractDublicateCount(loc project, str ext)
{
	
}

public list[int] ExtractUnitSizes(loc project)
{
}

public int ExtractAssertCount(loc project)
{}
