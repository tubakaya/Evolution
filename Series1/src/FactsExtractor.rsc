module FactsExtractor
import util::FileSystem;
import List;
import IO;

import lang::java::jdt::m3::Core;

/* Right now extracting all the lines..
It should extract only code lines!!*/
public int extractTotalLOC(loc project, str ext)
{
							  list[loc] allFiles = [f | /file(f) <- crawl(project), f.extension == ext];	
	  allLines = [readFileLines(f) | loc f <- allFiles];
	  codeLines = [l |l<-allLines, size(l)>0];
	  return (0 | it +1 | f <- codeLines);
}

/*If we really need to do this with M3, then fill this method
public int extractTotalLOCM3(loc project, str ext)
{}*/
