module FactExtractors::MethodInfoExtractor

//TODO: using the next import makes Rascal go NUTS (performance wise)!!
import lang::java::\syntax::Java15;
import ParseTree;
import List;
import Set;
import Utils;

import FactsType;
import FactExtractors::ExtractorCommon;


public list[MethodInfoType] ExtractMethodInfo(loc project, str ext)
{
  list[loc] allFiles = GetAllFiles(project, ext);
  
  int totalFiles = size(allFiles);
  debug("total files = <totalFiles>");
  
  debug("extracting methods...");
  int i = 1;
  set[MethodDec] methods = {};
  for(f <- allFiles) {
    debug("\t<i>/<totalFiles>: <f>"); i = i + 1;
    
    	methods += {m | /MethodDec m := parse(#start[CompilationUnit], f)};
  }
  
  int totalMethods = size(methods);
  debug("total methods = <totalMethods>");

  debug("getting method info...");
  i = 1;
  list[MethodInfoType] result = [];
  for(method <- methods) {
    debug("\t<i>/<totalMethods>: <method@\loc>"); i = i + 1;
    
    	result += MethodInfo(
  	              method@\loc,
  	              size(GetCodeLines(method@\loc)),
  	              CyclomaticComplexity(method)
  	            );
  }
  
  debug("done extracting method info..."); 
   
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

