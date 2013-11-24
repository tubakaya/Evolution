module FactExtractors::MethodInfoExtractor

//TODO: using the next import makes Rascal go NUTS (performance wise)!!
import lang::java::\syntax::Java15;
import ParseTree;
import List;
import Set;
import Utils;

import FactsType;
import FactExtractors::ExtractorCommon;


/*
  Get information about all method in project. 
*/
public list[MethodInfoType] ExtractMethodInfo(loc project, list[loc] allFiles)
{
  /*debug*/ debug("extracting method info...");
  /*debug*/ debug("\tproject = <project>");

  list[MethodInfoType] result = [];
  
  /*debug*/ int totalFiles = size(allFiles);
  /*debug*/ debug("\ttotal files = <totalFiles>");
  /*debug*/ int i = 1;

  set[MethodDec] methods = {};
  for(f <- allFiles) {
    /*debug*/ debug("\t<i>/<totalFiles>: <f>");
    /*debug*/ i = i + 1;
    
    methods = {m | /MethodDec m := parse(#start[CompilationUnit], f)};

    /*debug*/ int totalMethods = size(methods);
    /*debug*/ debug("\t\ttotal methods = <totalMethods>");
    /*debug*/ int j = 1;
    
    for(method <- methods) {
      /*debug*/ debug("\t\t<j>/<totalMethods>: <method@\loc>");
      /*debug*/ j = j + 1;
    
      result += MethodInfo(
                        method@\loc,
                        size(GetCodeLines(method@\loc)),
                        CyclomaticComplexity(method),
                        CountAssertion(method)
                      );
    }
  }
  
  /*debug*/ debug("done extracting method info...");
   
  return result;
}

/*
  Calculate CyclomaticComplexity: from http://www.rascal-mpl.org/#_Metrics
*/
int CyclomaticComplexity(MethodDec m) {
  result = 1;
  //TODO: it is not counting the ternary operator: `<expr> ? <expr> : <expr>;`
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

/*
  Count assert statements
*/
int CountAssertion(MethodDec m) {
  result = 0;
  visit (m) {
    case (Stm)`assert <Expr _> ;`: result += 1;
    case (Stm)`assert <Expr _> : <Expr _> ;`: result += 1;
  }
  return result;
}
