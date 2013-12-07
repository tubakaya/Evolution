module DependencyExtractor

import lang::java::m3::Core;
import Types;
import String;

public DependencyInfo ExtractPackageLevelDependencyInfo(M3 m3Model)
{
	set[loc] packages = packages(m3Model);
	set[str] packageNames = {p.path | p <- packages
										, !isEmpty(trim(p.path))
										, p.path != "/"}; 
	rel[loc from, loc to] dependencies = m3Model@typeDependency;
	
	map[str package, int totalDependencies] packageDependencies = ();	
	rel[loc from, loc to] result = {};
	
	for(n <- packageNames)
	{
		int counter = 0;
		for(e <- dependencies)
		{			
			if(isCompilationUnit(e.from)
				,contains(e.from.path, n)
				,isClass(e.to)
				,!startsWith(e.to.path,"/java/"))
			{
				result += e;
				counter += 1;
			}
		}
		packageDependencies += (n:counter);
	}

	return PackageLevelDependencyInfo(packageDependencies, result);
}

public DependencyInfo ExtractClassLevelDependencyInfo(rel[loc from, loc to] dependencies)
{
	rel[loc from, loc to] result = {e | e <- dependencies, isClass(e.to), startsWith(e.to.path,"/java/") == false};
	return ClassLevelDependencyInfo(result);
}

public rel[loc from, loc to] GetM3(loc project)
{
	M3 m3Model = createM3FromDirectory(project);
	return m3Model@typeDependency;	
}