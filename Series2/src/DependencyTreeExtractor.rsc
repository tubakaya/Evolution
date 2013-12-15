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
	
	set[loc] allClasses = classes(m3Model);
	for(cl<-allClasses)
	{
		DependencyTree dependencyTree = GetDependencyTree(cl,dependencies);
		WriteJsonForClassDependencyTree(cl, dependencyTree);
	}
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
private void WriteJsonForClassDependencyTree(loc class, DependencyTree dependencyTree)
{	
	loc file = |home:///Desktop/Series2/temp.txt|;
  	writeFile(file, dependencyTree); 
}

private DependencyTree GetDependencyTree(loc class, rel[loc from, loc to] dependencies)
{
	map[loc location,int count] depCount= GetDependenciesAndCount(class, dependencies);

	str name=last(split("/",class.path));
	loc physicalLoc=GetPhysicalLoc(class);
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
	map[loc location,int count] depCount= GetDependenciesAndCount(class, dependencies);

	str name=last(split("/",class.path));
	loc physicalLoc=GetPhysicalLoc(class);
	int totalLOC=GetLOC(class);
	
	return DependencyTree(name,
						params(
								physicalLoc
								,totalLOC
								,CalculateCC(physicalLoc,totalLOC)
								,dependencyCount)
						,size(depCount)> 0 ?
							[GetDependencyTreeForChild(d,dependencies,depCount[d])|d<-depCount]
							: []);
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
		
	if(size(cLoc) == 1)
	{
		return cLoc[0];
	}
	else
	{
		return null;
	}	
}

private int CalculateCC(loc location, int LOC)
{
	ClassFacts cf = ClassFacts(location
								,ExtractMethodInfo(location)
								,LOC);
	return AnalyzeComplexity(cf);
}