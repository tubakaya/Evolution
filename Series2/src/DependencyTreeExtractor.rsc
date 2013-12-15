module DependencyTreeExtractor

import Types;
import CCAnalyzer;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import String;
import List;
import Set;
import Map;
import IO;

import FactExtractors::ExtractorCommon;
import MethodInfoExtractor;
import Ranking;
import lang::json::IO;

loc project;
set[loc] compilationUnits;

public void ExtractClassDependencies(loc location)
{
	project=location;
	M3 m3Model = createM3FromEclipseProject(project);	
	compilationUnits = files(m3Model@containment);
	
	set[str] packages = GetAllPackageNames(m3Model);	
	rel[loc from, loc to] dependencies = {r | r <- m3Model@typeDependency
											, InPackages(r.from, packages)
											, InPackages(r.to, packages)};
	
	set[loc] allClasses ={ c
							|c <- classes(m3Model)
							,cu <- compilationUnits
							,contains(cu.path, c.path)};
	

	map[loc location,str fileName] classFileNames = GetClassFileNames(allClasses);
	WriteClassAndFileNamesToJson(classFileNames);
	
	for(cl<-allClasses)
	{
		DependencyTree dependencyTree = GetDependencyTree(cl,dependencies);
		WriteJsonForClassDependencyTree(classFileNames[cl], dependencyTree);
	}
}

private map[loc location,str fileName] GetClassFileNames(set[loc] allClasses)
{
	map[loc location,str fileName] classFileNames =();
	for(c<-allClasses)
	{
		str className = replaceAll(c.path,"/",".");
		className = substring(className,1);
		classFileNames +=(c:className);
	}
	return classFileNames;
}

private void WriteClassAndFileNamesToJson(map[loc location,str fileName] classFileNames)
{
	str text="{\"classes\": [";
		
	for(c <- classFileNames)
	{		
		text += "\"<classFileNames[c]>\",";
	}
	text = substring(text,0,size(text)-1);
	text+="]}";
	 
	loc file = |home:///Desktop/Series2/classFileNames.json|;
  	writeFile(file, text); 
}

private set[str] GetAllPackageNames(M3 m3Model)
{
	return {e.path | e <- m3Model@containment<from>
						, isPackage(e)
						, trim(e.path)!="/"};
}

private bool InPackages(loc file, set[str] packages)
{
	bool result = false;
	for(p <- packages)
	{
		if(startsWith(file.path,p))
		{
			result=true;
			break;
		}
	}
	return result;
}
private void WriteJsonForClassDependencyTree(str fileName, DependencyTree dependencyTree)
{	
	str text="{";
	text+= "\"name\": \"<dependencyTree.name>\",";
	text+= "\"params\": {";
		text+="\"location\": \"<dependencyTree.params.location>\",";
		text+="\"LOC\": <dependencyTree.params.LOC>,";
		text+="\"CC\": <dependencyTree.params.CC>";
	text+="},";
	text+="\"children\": [";			
	for(c <- dependencyTree.children)
	{
		text+=GetTextForChild(c);
		text += ",";
	}
	if(size(dependencyTree.children)>0)
	{
		text = substring(text,0,size(text)-1);
	}
	text+="]}";
	 
	loc file = |home:///Desktop/Series2/<fileName>.json|;
  	writeFile(file, text); 
}

private str GetTextForChild(DependencyTree dependencyTree)
{
	str text = "{";
	text+= "\"name\": \"<dependencyTree.name>\",";
	text+= "\"params\": {";
		text+="\"location\": \"<dependencyTree.params.location>\",";
		text+="\"LOC\": <dependencyTree.params.LOC>,";
		text+="\"CC\": <dependencyTree.params.CC>,";
		text+="\"dependencyCount\": <dependencyTree.params.dependencyCount>";
	text+="},";
	text+="\"children\": [";
	if(size(dependencyTree.children)>0)
	{
		for(dc<-dependencyTree.children)
		{
			text+=GetTextForChild(dc);
		}
	}

	text+="]}";
	return text;
}

set[loc] visitedClasses;
private DependencyTree GetDependencyTree(loc class, rel[loc from, loc to] dependencies)
{
	visitedClasses={class};

	map[loc location,int count] depCount= GetDependenciesAndCount(class, dependencies);

	str name=last(split("/",class.path));
	loc physicalLoc = GetPhysicalLoc(class);
	int totalLOC=GetLOC(class);
	
	
	return DependencyTree(name,
						params(
								physicalLoc
								,totalLOC
								,CalculateCC(physicalLoc,totalLOC))
						,size(depCount)> 0 ?
							[GetDependencyTreeForChild(d,dependencies,depCount[d])|d<-depCount]
							: []);
							
}

private DependencyTree GetDependencyTreeForChild(loc class, rel[loc from, loc to] dependencies, int dependencyCount)
{
	str name = last(split("/",class.path));
	loc physicalLoc = GetPhysicalLoc(class);
	int totalLOC = GetLOC(class);
	
	params parameters = params(physicalLoc
						,totalLOC
						,CalculateCC(physicalLoc,totalLOC)
						,dependencyCount);
	DependencyTree dt = DependencyTree(name,parameters,[]) ;
					
	if(class in visitedClasses)
	{
		return dt;
	}
	
	visitedClasses += class;
	
	map[loc location,int count] depCount= GetDependenciesAndCount(class, dependencies);
	dt.children = size(depCount) > 0 ?
							[GetDependencyTreeForChild(d,dependencies,depCount[d])
								|d<-depCount]
							: [];
							
	return dt;
}

private map[loc location,int count] GetDependenciesAndCount(loc class, rel[loc from, loc to] dependencies)
{
	map[loc location,int count] depCount=();
	
	for(r <- dependencies)
	{
		if(r.to != class && contains(r.from.path,class.path))
		{
			if(r.to in depCount)
			{
				depCount[r.to] += 1;
			}
			else
			{
				depCount += (r.to : 1);
			}
		}
	}
	return depCount;
}

private loc GetPhysicalLoc(loc logicalLoc)
{
	list[loc] cLoc = [project + cu.path |cu <- compilationUnits
											,contains(cu.path, logicalLoc.path)];
	
	if(size(cLoc)<1)
	{
		return logicalLoc;
	}
	
	return cLoc[0];
}

private int CalculateCC(loc location, int LOC)
{
	ClassFacts cf = ClassFacts(location
								,ExtractMethodInfo(location)
								,LOC);
	return AnalyzeComplexity(cf);
}