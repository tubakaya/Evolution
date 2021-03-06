module Types

import Ranking;

data MethodInfo = MethodInfo(
  loc location,
  int LOC,
  int complexity
);

data ClassFacts = ClassFacts(
  loc location,
  list[MethodInfo] methods,
  int totalLOC
);

data ClassInfo = ClassInfo(
  loc location,
  str name,
  int LOC,
  int CC,
  map[loc depOn, int count] dependencies
);

data VisualizationData = VisualizationData(
  list[ClassInfo] classes
);

data params = params(loc location,int LOC, int CC)
				|  params(loc location,int LOC, int CC, int dependencyCount);
				
data DependencyTree = DependencyTree(loc From, list[DependencyTree] children)
					| DependencyTree(str name, params params, list[DependencyTree] children);
					
					