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
	list[list[str]] codeLines = [GetCodeLines(f) | f <- allFiles ];
	
	int counter = 0;
	for( i <- [0..size(codeLines)])
	{
		counter += size(codeLines[i]);
	}
	
	return counter;
}

/*Extract the total amount of Switch, If, For and While statements*/
public int ExtractTotalStatCount(loc project)
{}

/*Extract the amount of duplicate code of at least 6 lines*/
public int ExtractDuplicateCount(loc project, str ext)
{
	int counter = 0;

	list[loc] allFiles = GetAllFiles(project, ext);
	
	list[loc] visitedFiles = [];
	for(f <- allFiles)
	{
		visitedFiles +=f;
		list[str] lines1 = readFileLines(f);
		for( f2 <- (allFiles - visitedFiles))
		{
			list[str] lines2 = readFileLines(f2);
			rel[str,str] equalLines = {<l1,l2> | l1 <- lines1, l2 <- lines2, l1 == l2};
			
			/*check the 6 lines starting with l1*/
			for( <el1,el2> <- equalLines)
			{
				int index1 = indexOf(lines1,el1) +1;
				int index2 = indexOf(lines1,el1) +1;
				
				bool duplicate = true;
				for(i<-[1..6])
				{
					if(lines1[index1] != lines2[index2])
					{
					 	duplicate = false;
						fail;
					}
					index1 +=1;
					index2 +=1;
				}
				
				if(dublicate)
				{
					count += 1;
				}
			}
		}
	}
	
	return count;
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

list[str] GetCodeLines(loc file)
{
	list[str] allLines = readFileLines(file);
	return [l | l <- allLines
				, !isEmpty(trim(l))
				, !startsWith(trim(l),"/*")
				, !endsWith(trim(l),"*/")];
}
