module FactExtractors::ExtractorCommon

//import lang::java::jdt::m3::Core;
//import lang::java::\syntax::Java15;
import util::FileSystem;
import IO;
import String;
//import ParseTree;

list[loc] GetAllFiles(loc project, str ext)
{
	return [f | /file(f) <- crawl(project), f.extension == ext];
}

list[str] GetCodeLines(loc location)
{
	list[str] allLines = readFileLines(location);
	return codeLines = [l | l <- allLines
					, !isEmpty(trim(l))
					, !startsWith(trim(l),"//")
					, !startsWith(trim(l),"/*")
					, !startsWith(trim(l),"*")
					, !endsWith(trim(l),"*/")];
}

/*
      data MethodInfo = methodInfo(loc method, int complexity, int LOC);
      data Facts = facts(
        int totalLOC, 
        list[MethodInfo] methods,
        ... information for duplication...
      );
*/ 


/*
public list[tuple[loc method, int CC, int lines]] ExtractComplexity(loc project, str ext)
{
  list[loc] allFiles = GetAllFiles(project, ext);
  set[MethodDec] methods = {};
  for(f <- allFiles)
  {
  	methods += {m | /MethodDec m := parse(#start[CompilationUnit], f)};
  }
  
  list[tuple[loc, int, int]] result = [];
  for(m <- methods)
  {
    int cc = CyclomaticComplexity(m);
  	int lines = size(GetCodeLines(m@\loc));
  	result += <m@\loc, cc, lines>;
  }

  return result;
}
*/