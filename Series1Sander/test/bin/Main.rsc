module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
//import lang::java::jdt::m3::AST;
import lang::java::\syntax::Java15;
//import lang::java::\syntax::Disambiguate;
import List;
import Exception;
import ParseTree;
import IO;
import Set;
import util::FileSystem;

loc MY_PROJECT = |project://HelloWorld|;

public void main() {
/*
  // own version
	
	
  myModel = getM3FromProject(MY_PROJECT);			
  //println("myModel: <myModel>");
  
  myMethods = toList(methods(myModel));
  //println("myMethods: <myMethods>");
  
  i = 1; // take second method
  //println("method: <readFile(myMethods[i])>");
  methodAST = getMethodAST(myMethods[i]);
  println("methodAST: <methodAST>");
  
  
  CC = calcCC(methodAST);
  println("CC: <CC>");
*/
  


  // version from website

  files2 = getFiles(MY_PROJECT);
  println("files2: <files>");

  //NOTE: currently take the first (0) file  
  methods2 = getMethods(files2[0]);
  println("methods2: <methods2>");
  
  rel2 = [<cyclomaticComplexity(m), m@\loc> | m <- methods2];
  println("rel2: <rel2>");
  
}


/*
	utility methods
*/
M3 getM3FromProject(loc project) {
  return createM3FromEclipseProject(project);
}

list[loc] getFiles(loc project) {
  result = [f | /file(f) <- crawl(project), f.extension == "java"];
  return result;	
}

set[MethodDec] getMethods(loc file) {
  result = {m | /MethodDec m := parse(#start[CompilationUnit], file)};
  return result;
}


/*
	calculate CC (based on type Declaration)
*/
int calcCC(Declaration m) {
  result = 1;
  visit (m) {
  	case /Statement (_): {
  		println("found");
  		result += 1;
  	}
  }
  return result;
}


/*
	calculate CC from http://www.rascal-mpl.org/#_Metrics
*/
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


lrel[int cc, loc method] findComplexFiles(loc project) {
  result = [*maxCC(f) | /file(f) <- crawl(project), f.extension == "java"];	
  result = sort(result, bool (<int a, loc _>, <int b, loc _>) { return a < b; });
  // return head(reverse(result), limit);
  return result;
}

set[MethodDec] allMethods(loc file) 
  = {m | /MethodDec m := parse(#start[CompilationUnit], file)};

lrel[int cc, loc method] maxCC(loc file) 
  = [<cyclomaticComplexity(m), m@\loc> | m <- allMethods(file)];
