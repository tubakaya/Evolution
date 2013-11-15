module FactsExtractor
import util::FileSystem;
import List;
import IO;

/* Right now extracting all the lines..
It should extract only code lines!!*/
public int extractTotalLOC(loc project, str ext)
{
	list[loc] allFiles = [f | /file(f) <- crawl(project), f.extension == ext];	
	return (0 | it + size(readFileLines(f)) | loc f <- allFiles);
}

