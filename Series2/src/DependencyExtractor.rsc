module DependencyExtractor

import Types;
//import CCAnalyzer;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import String;
import List;
import Set;

import FactExtractors::ExtractorCommon;
import FactExtractors::MethodInfoExtractor;
import Ranking;

public VisualizationData ExtractClassDependencies(loc projectLoc)
{
	project = projectLoc;
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
								,1
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
						,1
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
		for(cu <- compilationUnits)
		{
			if(contains(cu.path, c.location.path))
			{
				ci.location = project + cu.path;
				break;
			}
		}
		
		for(d <- c.dependencies)
		{
			for(cu <- compilationUnits)
			{
				if(contains(cu.path, d.path))
				{
					int count = c.dependencies[d];
					ci.dependencies -= (d:count);
					ci.dependencies +=  (project + cu.path : count);
					break;
				}
			}
		}
		toReturn += ci;
	}
	
	return toReturn;
}