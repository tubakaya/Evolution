module DependencyExtractor

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import Types;
import String;
import Set;
import Ranking;
import FactExtractors::ExtractorCommon;
import List;

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
								,Low(5)
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
	return [ClassInfo(c
							,c.path
							,GetLOC(c)
							,Low(5)
							,())
							|c <- allClasses
							,c notin classesAlreadyFound ];	
}