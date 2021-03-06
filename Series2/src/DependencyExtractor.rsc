module DependencyExtractor

import Types;
import CC::CCAnalyzer;
import CC::MethodInfoExtractor;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import String;
import List;
import Set;

import FactExtractors::ExtractorCommon;
import Ranking;

public VisualizationData ExtractClassDependencies(loc project)
{
	M3 m3Model = createM3FromEclipseProject(project);	
	set[str] packages = GetAllPackageNames(m3Model);
	
	rel[loc from, loc to] dependencies = {r | r <- m3Model@typeDependency
											, InPackages(r.from, packages)
											, InPackages(r.to, packages)};
	
	map[tuple[loc from, loc to] dep, int count] classToClassDependencies
						= GetClassToClassDependencies(m3Model, dependencies);
								
	list[ClassInfo] classInfos = GetDependentClassInfos(classToClassDependencies);
	
	set[loc] allClasses = classes(m3Model);
	set[loc] classesAlreadyFound = {c.location |c <- classInfos};	
	classInfos += GetIndependentClassInfos(allClasses, classesAlreadyFound);
	
	classInfos = MakeLocsPhysical(project, m3Model,	classInfos);
	classInfos = CalculateCC(classInfos);										
	return VisualizationData(classInfos);
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

private map[tuple[loc from, loc to] dep, int count] GetClassToClassDependencies(M3 m3Model,rel[loc from, loc to] dependencies )
{
	map[tuple[loc from, loc to] dep, int count] classToClassDependencies = ();									
	for(d <- dependencies)
	{
		while(!isClass(d.from))
		{
			d.from = [e.from |e <- m3Model@containment, e.to == d.from][0];			
		}
		
		if(d.from!=d.to)
		{
			if(<d.from, d.to> in classToClassDependencies)
			{
				classToClassDependencies[<d.from,d.to>] += 1;
			}
			else
			{
				classToClassDependencies += (<d.from, d.to> : 1);
			}
		}
	}
	
	return classToClassDependencies;
}

private list[ClassInfo] GetDependentClassInfos(map[tuple[loc from, loc to] dep, int count] classToClassDependencies)
{
	list[ClassInfo] classInfos = [];
	set[loc] froms = {c.from | c <- classToClassDependencies};

	for(f <- froms)
	{	
		ClassInfo ci = ClassInfo(f
								,f.path
								,GetLOC(f)
								,0
								,());
		
		map[loc to, int count] dep = (c.to : classToClassDependencies[c] 
												| c <- classToClassDependencies
												, c.from == f);
		ci.dependencies = dep;
		classInfos += ci;
	}	
	return classInfos;
}

private list[ClassInfo] GetIndependentClassInfos(set[loc] allClasses, set[loc] classesAlreadyFound)
{
	return 	[ClassInfo(c
						,c.path
						,GetLOC(c)
						,0
						,())
						|c <- allClasses
						,c notin classesAlreadyFound];	
}

private list[ClassInfo] MakeLocsPhysical(loc project,M3 m3Model, list[ClassInfo] classInfos)
{
	set[loc] compilationUnits = files(m3Model@containment);
	list[ClassInfo] toReturn = [];
	for(c <- classInfos)
	{
		ClassInfo ci = c;
		
		list[loc] cLoc = [project + cu.path |cu <- compilationUnits
											,contains(cu.path, c.location.path)];
		
		if(size(cLoc) == 1)
		{
			ci.location = cLoc[0];
		}
		else if(size(cLoc) == 0)
		{
			break;
		}
		
		for(d <- c.dependencies)
		{
			int count = c.dependencies[d];
			ci.dependencies -= (d:count);
			for(cu <- compilationUnits)
			{
				if(contains(cu.path, d.path))
				{					
					ci.dependencies +=  (project + cu.path : count);
					break;
				}
			}
		}
		toReturn += ci;
	}
	
	return toReturn;
}

private list[ClassInfo] CalculateCC(list[ClassInfo] classInfos)
{
	list[ClassInfo] clone = classInfos;
	for(i <- [0..size(clone)])
	{		
		ClassFacts cf = ClassFacts(clone[i].location
									,ExtractMethodInfo(clone[i].location)
									,clone[i].LOC);
		clone[i].CC = AnalyzeComplexity(cf);
	}
	return clone;
}