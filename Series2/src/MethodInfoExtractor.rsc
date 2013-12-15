@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module MethodInfoExtractor

//TODO: using the next import makes Rascal go NUTS (performance wise)!!
import lang::java::\syntax::Java15;
import List;
import Set;

import Types;
import FactExtractors::ExtractorCommon;
import ParseTree;

/*
  Get information about all method in project. 
*/
public list[MethodInfo] ExtractMethodInfo(loc class)
{
  list[MethodInfo] result = [];

  set[MethodDec] methods = {};
    
    tree = parse(#start[CompilationUnit], class);
    methods = {m | /MethodDec m := tree};
    
    for(method <- methods) {
    
      result += MethodInfo(
                        method@\loc,
                        GetLOC(method@\loc),
                        CyclomaticComplexity(method)
                      );
    }
   
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