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


map[loc,int] locCC=();
map[loc,loc] locPhysical=();
map[loc,map[loc location,int count]] locDepCount = ();

public M3 GetM3Model(loc location)
{
	M3 m3Model =  createM3FromEclipseProject(location);	
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

public set[loc] GetAllClassFiles(M3 m3Model,set[loc] compilationUnits)
{	
	set[loc] allClasses = { c
							|c <- classes(m3Model)
							,cu <- compilationUnits
							,contains(cu.path, c.path)
							,!contains(c.path,"junit")
							,!contains(c.path,"test")};	
	debug("found all classes (that have a file). Count: <size(allClasses)>");	
	return allClasses;
}

public void WriteDependencyTrees(rel[loc from, loc to] dep,map[loc location,str fileName] classFileNames,set[loc] compilationUnits,loc project)
{
	for(cl <- classFileNames)
	{
		loc file = |home:///Desktop/Series2/<classFileNames[cl]>.json|;
		if(!exists(file))
		{
			DependencyTree dependencyTree = GetDependencyTree(cl,dep,compilationUnits,project);
			debug("DependencyTree generated.");
			WriteJsonForClassDependencyTree(classFileNames[cl], dependencyTree);
			debug("DependencyTree written in json file.");
		}
	}
}

public map[loc location,str fileName] GetClassFileNames(set[loc] allClasses)
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
	
	set[loc] compilationUnits = files(m3Model@containment);
	set[loc] allClasses = GetAllClassFiles(m3Model,compilationUnits);
	
	map[loc location,str fileName] classFileNames=GetClassFileNames(allClasses);
	WriteClassAndFileNamesToJson(classFileNames);
	
	rel[loc from, loc to] dep = {d | d<-dependencies, isClass(d.to), InCompilationUnits(d.to,compilationUnits)};
	WriteDependencyTrees(dep, classFileNames,compilationUnits,location);
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


public bool InCompilationUnits(loc file, set[loc] compilationUnits)
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
map[loc, int] childrenLevel;

private DependencyTree GetDependencyTree(loc class, rel[loc from, loc to] dependencies,set[loc] compilationUnits,loc project)
{
	childrenLevel = (class:1);
	debug("\tStarted GetDependencyTree for class <class.path>");
	visitedClasses = {class};

	map[loc location,int count] depCount= GetDependenciesAndCount(class, dependencies);

	str name=last(split("/",class.path));
	loc physicalLoc = GetPhysicalLoc(class,compilationUnits,project);
	int totalLOC = GetLOC(class);	
	
	DependencyTree dt=DependencyTree(name,
						params(
								physicalLoc
								,totalLOC
								,CalculateCC(physicalLoc,totalLOC))
								,[]);
	if(size(depCount)> 0)
	{	
		for(d<-depCount)
		{
			childrenLevel += (d:2);
		}	

		dt.children=[GetDependencyTreeForChild(d,dependencies,depCount[d],compilationUnits,project)|d<-depCount];
	}
	
	return dt;
}

private DependencyTree GetDependencyTreeForChild(loc class, rel[loc from, loc to] dependencies, int dependencyCount,set[loc] compilationUnits,loc project)
{
	debug("\t\tChild class: <class.path>");
	str name = last(split("/",class.path));
	loc physicalLoc = GetPhysicalLoc(class,compilationUnits,project);
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
	
	int currentLevel = childrenLevel[class];
	if(size(depCount) > 0 && currentLevel<5)
	{				
		debug("<size(depCount)> children added to level <currentLevel+1>...");	
		debug("Total size of childrenLevel map is <size(childrenLevel)>");	
		debug("Class is <class>");
		debug("Children are:");
		
		for(d<-depCount)
		{
			childrenLevel += (d:currentLevel+1);
			debug("<d>");
		}
		
		dt.children = [GetDependencyTreeForChild(d,dependencies,depCount[d],compilationUnits,project)
					|d<-depCount
					,d notin visitedClasses];
	}			
	return dt;
}

private map[loc location,int count] GetDependenciesAndCount(loc class, rel[loc from, loc to] dependencies)
{
	if(class notin locDepCount)
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
		
		locDepCount += (class:depCount);
		return depCount;
	}
	else
	{
		return locDepCount[class];
	}
}


private loc GetPhysicalLoc(loc logicalLoc, set[loc]  compilationUnits, loc project)
{
	if(logicalLoc notin locPhysical)
	{
		list[loc] cLoc = [project + cu.path |cu <- compilationUnits
												,last(split("/",cu.path)) == (last(split("/",logicalLoc.path)) + ".java")];
		
		if(size(cLoc)<1)
		{
			return logicalLoc;
		}
		
		locPhysical += (logicalLoc:cLoc[0]);
		return cLoc[0];
	}
	else
	{
		return locPhysical[logicalLoc];
	}
}


private int CalculateCC(loc location, int LOC)
{
	int CC = 0;
	if(location notin locCC)
	{
		ClassFacts cf = ClassFacts(location
								,ExtractMethodInfo(location)
								,LOC);
		CC = AnalyzeComplexity(cf);
		locCC += (location:CC);
		return CC;
	}
	else
	{
		return locCC[location];
	}
}