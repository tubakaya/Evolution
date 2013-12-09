module DependencyExtractor

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import Types;
import String;
import Utils;

public DependencyInfo ExtractPackageLevelDependencyInfo(M3 m3Model)
{
	set[loc] packages = {e | e <- m3Model@containment<from>
								, isPackage(e)
								, trim(e.path)!="/"};
								
	rel[loc from, loc to] dependencies = {r | r <- m3Model@typeDependency
											, p <- packages
											, startsWith(r.from.path, p.path) || startsWith(r.to.path, p.path)};
	
	rel[loc fromPackage, loc toPackage, int dependencyCount] packageDependencies = {};	
	
	for(n1 <- packages, n2 <- packages,n1 != n2)
	{
		int counter = 0;
		for(e <- dependencies)
		{		
			if(contains(e.from.path, n1.path)
				,contains(e.to.path, n2.path))
			{
				counter += 1;						
			}
		}
		packageDependencies += (<n1, n2, counter>);
	}

	return PackageLevelDependencyInfo(packageDependencies);
}

public DependencyInfo ExtractClassLevelDependencyInfo(rel[loc from, loc to] dependencies)
{
	rel[loc from, loc to] result = {e | e <- dependencies, isClass(e.to), startsWith(e.to.path,"/java/") == false};
	return ClassLevelDependencyInfo(result);
}

public rel[loc from, loc to] GetM3(loc project)
{
	M3 m3Model = createM3FromEclipseProject(project);
	return m3Model@typeDependency;	
}