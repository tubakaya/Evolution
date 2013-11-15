module Main

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import List;
import Exception;
import ParseTree;
import IO;
import util::FileSystem;
import lang::java::\syntax::Disambiguate;
import lang::java::\syntax::Java15;

import CyclomaticComplexity;

loc MY_PROJECT = |project://HelloWorld|;

public void main() {
  myModel = getM3FromProject(getProject());			
  println("this is myModel: <myModel>");
  
  complexFiles = findComplexFiles(getProject());
  println("this is complexFiles: <complexFiles>");
  
  myMethods = [getMethods(q) | q <- getFiles(getProject())];
  println("this is myMethods: <myMethods>");
}

loc getProject() {
		  return MY_PROJECT;
}

list[loc] getFiles(loc project) {
  result = [f | /file(f) <- crawl(project), f.extension == "java"];
  return result;	
}

set[MethodDec] getMethods(loc file) {
  result = {m | /MethodDec m := parse(#start[CompilationUnit], file)};
  return result;
}


M3 getM3FromProject(loc project) {
	  return createM3FromEclipseProject(project);
}



// from http://www.rascal-mpl.org/#_Metrics
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
