module FactExtractors::ExtractorCommon

import util::FileSystem;
import IO;
import String;
/*import lang::java::jdt::m3::AST;
* Need this import for GetAllMethods
*/

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

list[loc] GetAllMethods(loc project)
{
	/*Get here all the methods using m3*/	
	return [];
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
public list[tuple[loc method, int CC, int lines]] GetMethodInfo(loc project, str ext)
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