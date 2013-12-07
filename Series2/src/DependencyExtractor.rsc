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
	
	rel[loc fromPackage, loc toPackage, int dependencyCount] packageDependencies = {};	
	
	for(n1 <- packageNames)
	{
		for(n2 <- packageNames)
		{
			if(n1 != n2)
			{
				int counter = 0;
				for(e <- dependencies)
				{			
					if(contains(e.from.path, n1)
						,contains(e.to.path, n2)
						,isClass(e.to)
						,!startsWith(e.to.path,"/java/"))
					{
						counter += 1;
					}
				}
				packageDependencies += (<n1, n2, counter>);
			}
		}
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
	M3 m3Model = createM3FromDirectory(project);
	return m3Model@typeDependency;	
}