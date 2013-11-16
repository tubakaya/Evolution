module FactsExtractor

import lang::java::jdt::m3::Core;
import lang::java::\syntax::Java15;
import util::FileSystem;
import List;
import IO;
import String;
import ParseTree;


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

/*
  Extract the Cyclomatic Complexity of all methods in project
  Return a map with method-location and a tuple with CC and number-of-lines
*/
public map[loc, tuple[int, int]] ExtractCC(loc project, str ext)
{
  list[loc] allFiles = GetAllFiles(project, ext);
  set[MethodDec] methods = {};
  for(f <- allFiles)
  {
  	methods += {m | /MethodDec m := parse(#start[CompilationUnit], f)};
  }
  
  map[loc, tuple[int, int]] result = ();
  for(m <- methods)
  {
    int cc = cyclomaticComplexity(m);
  	int lines = size(readFileLines(m@\loc));
  	result += (m@\loc : <cc, lines>);
  }
  return result;
}

//	calculate CC from http://www.rascal-mpl.org/#_Metrics
int cyclomaticComplexity(MethodDec m) {
  result = 1;
  visit (m) {
    case (Stm)`do <Stm _> while (<Expr _>);`: result += 1;
    case (Stm)`while (<Expr _>) <Stm _>`: result += 1;
    case (Stm)`if (<Expr _>) <Stm _>`: result +=1;
    case (Stm)`if (<Expr _>) <Stm _> else <Stm _>`: result +=1;
    case (Stm)`for (<{Expr ","}* _>; <Expr? _>; <{Expr ","}*_>) <Stm _>` : result += 1;
    case (Stm)`for (<LocalVarDec _> ; <Expr? e> ; <{Expr ","}* _>) <Stm _>`: result += 1;
    case (Stm)`for (<FormalParam _> : <Expr _>) <Stm _>` : result += 1;
    case (Stm)`switch (<Expr _> ) <SwitchBlock _>`: result += 1;
    case (SwitchLabel)`case <Expr _> :` : result += 1;
    case (CatchClause)`catch (<FormalParam _>) <Block _>` : result += 1;
  }
  return result;
}



/*Extract the amount of duplicate code of at least 6 lines*/
public int ExtractDuplicateCount(loc project, str ext)
{
	int counter = 0;

	list[loc] allFiles = GetAllFiles(project, ext);
	
	map[loc, list[str]] fileCodeLines = (f:GetCodeLines(f) | f <- allFiles);
	map[loc, list[str]] compareList = fileCodeLines;
	for((f:lines1) <- fileCodeLines)
	{
		compareList = delete(compareList, f);
		for( (f2:lines2) <- compareList)
		{
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
