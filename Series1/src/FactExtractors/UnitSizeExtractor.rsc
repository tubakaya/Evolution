module FactExtractors::UnitSizeExtractor
import FactExtractors::ExtractorCommon;

/*
  Extract the LOC of all methods in project
  Return a list of LOC per method
*/
//TODO: this basicly does the same as ExtractComplexity!!
public list[int] ExtractUnitSizes(loc project, str ext)
{
  list[loc] allFiles = GetAllFiles(project, ext);
  set[MethodDec] methods = {};
  for(f <- allFiles)
  {
  	methods += {m | /MethodDec m := parse(#start[CompilationUnit], f)};
  }
  
  list[int] result = [];
  for(m <- methods)
  {
  	result += size(GetCodeLines(m@\loc));
  }

  return result;
}