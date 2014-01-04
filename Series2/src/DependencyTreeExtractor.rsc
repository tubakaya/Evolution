module DependencyTreeExtractor

import Types;
import CC::CCAnalyzer;
import CC::MethodInfoExtractor;
import IO::FileWriter;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import String;
import List;
import Set;
import Map;
import IO;

import FactExtractors::ExtractorCommon;
import Ranking;
import Utils;

loc project;
set[loc] compilationUnits;

public M3 GetM3Model(loc location)
{
	project=location;
	M3 m3Model =  createM3FromEclipseProject(project);	
	return m3Model;
}

public rel[loc from, loc to] GetDependenciesWithinPackages(M3 m3Model)
{
	set[str] packages = GetAllPackageNames(m3Model);
	debug("found package names.");	
	rel[loc from, loc to] dependencies = {r | r <- m3Model@typeDependency
											, InPackages(r.from, packages)
											, InPackages(r.to, packages)};
	return dependencies;
}

public set[loc] GetAllClassFiles(M3 m3Model)
{
	compilationUnits = files(m3Model@containment);
	set[loc] allClasses = { c
							|c <- classes(m3Model)
							,cu <- compilationUnits
							,contains(cu.path, c.path)
							,!contains(c.path,"junit")
							,!contains(c.path,"test")};	
	debug("found all classes (that have a file). Count: <size(allClasses)>");	
	return allClasses;
}

public void WriteDependencyTrees(rel[loc from, loc to] dependencies,map[loc location,str fileName] classFileNames)
{
	rel[loc from, loc to] dep = {d | d<-dependencies, isClass(d.to), InCompilationUnits(d.to)};
	for(cl <- classFileNames)
	{
		DependencyTree dependencyTree = GetDependencyTree(cl,dep);
		debug("DependencyTree generated.");
		WriteJsonForClassDependencyTree(classFileNames[cl], dependencyTree);
		debug("DependencyTree written in json file.");
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


public void ExtractClassDependencies(loc location)
{
	debug("Started class dependency extraction...");
	M3 m3Model = GetM3Model(location);
	rel[loc from, loc to] dependencies = GetDependenciesWithinPackages(m3Model);
	
	set[loc] allClasses = GetAllClassFiles(m3Model);
	
	map[loc location,str fileName] classFileNames=GetClassFileNames(allClasses);
	WriteClassAndFileNamesToJson(classFileNames);
	
	WriteDependencyTrees(dependencies, classFileNames);
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


private bool InCompilationUnits(loc file)
{
	bool result = false;
	for(cu <- compilationUnits)
	{
		if(contains(cu.path, file.path))
		{
			result=true;
			break;
		}
	}
	return result;
}

set[loc] visitedClasses;
private DependencyTree GetDependencyTree(loc class, rel[loc from, loc to] dependencies)
{
	debug("\tStarted GetDependencyTree for class <class.path>");
	visitedClasses = {class};

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
	debug("\t\tChild class: <class.path>");
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
								|d<-depCount
								,d notin visitedClasses]
							: [];
							
	return dt;
}

private map[loc location,int count] GetDependenciesAndCount(loc class, rel[loc from, loc to] dependencies)
{
	map[loc location,int count] depCount=();
	
	for(r <- dependencies, r.to != class && contains(r.from.path,class.path))
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