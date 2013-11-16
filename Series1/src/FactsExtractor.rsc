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
	allLines = [readFileLines(f) | loc f <- allFiles];
	codeLines = [l | m <- allLines, l <- m
					, !isEmpty(trim(l))
					, !startsWith(trim(l),"/*")
					, !endsWith(trim(l),"*/")];
	return size(codeLines);	
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
