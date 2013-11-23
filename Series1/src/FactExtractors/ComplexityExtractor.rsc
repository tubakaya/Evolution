module FactExtractors::ComplexityExtractor

import FactExtractors::ExtractorCommon;

import lang::java::\syntax::Java15;
import ParseTree;
import List;

/*
  Extract the Cyclomatic Complexity of all methods in project
  Return a list of tuples with (method-location, CC, number-of-lines)
*/
//data MethodInfo = methodInfo(loc method, int complexity, int LOC);
//data MethodsInfo = methodsInfo(list[MethodInfo] methods);
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

/*
  Calculate CyclomaticComplexity: from http://www.rascal-mpl.org/#_Metrics
*/
int CyclomaticComplexity(MethodDec m) {
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