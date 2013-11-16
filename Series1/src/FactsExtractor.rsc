module FactsExtractor
import util::FileSystem;
import List;
import IO;

import lang::java::jdt::m3::Core;

/* Right now extracting all the lines..
It should extract only code lines!!*/
public int ExtractTotalLOC(loc project, str ext)
{
							  list[loc] allFiles = [f | /file(f) <- crawl(project), f.extension == ext];	
	  allLines = [readFileLines(f) | loc f <- allFiles];
	  codeLines = [l |l<-allLines, size(l)>0];
	  return (0 | it +1 | f <- codeLines);
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
