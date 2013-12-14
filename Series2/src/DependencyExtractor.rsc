module DependencyExtractor

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import Types;
import String;
import Utils;
import Set;
import Ranking;

public VisualizationData ExtractClassDependencies(loc project)
{
	M3 m3Model = createM3FromEclipseProject(project);
	set[str] packages = {e.path | e <- m3Model@containment<from>
								, isPackage(e)
								, trim(e.path)!="/"};
	
	rel[loc from, loc to] dependencies = {r | r <- m3Model@typeDependency
											, InPackages(r.from, packages)
											, InPackages(r.to, packages)};
	
	map[tuple[loc from, loc to] dep, int count] classToClassDependencies
						= GetClassToClassDependencies(m3Model, dependencies);
								
	list[ClassInfo] classInfos = [ClassInfo(d.from
											,d.from.path
											,50
											,Low(5)
											,(d.to : classToClassDependencies[d]))
											| d <- classToClassDependencies];
	
	set[loc] allClasses = classes(m3Model);
	set[loc] classesAlreadyFound = {c.location |c <- classInfos};
	classInfos += [ClassInfo(c
							,c.path
							,50
							,Low(5)
							,())
							|c <- allClasses
							,c notin classesAlreadyFound ];	
															
	return VisualizationData(classInfos);
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
			debug("\tfrom:<d.from>");	
			d.from = [e.from |e <- m3Model@containment, e.to == d.from][0];	
			debug("\tfrom after:<d.from>");			
		}
		if(<d.from, d.to> in classToClassDependencies)
		{
			classToClassDependencies[<d.from,d.to>] += 1;
		}
		else
		{
			classToClassDependencies += (<d.from, d.to> : 1);
		}
	}
	
	return classToClassDependencies;
}