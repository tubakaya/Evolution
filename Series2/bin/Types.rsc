module Types

import Ranking;
import FactsType;

//TODO: needed for visualization
data DependencyInfo = 
	PackageLevelDependencyInfo(rel[loc fromPackage, loc toPackage, int dependencyCount])
	| ClassLevelDependencyInfo(rel[loc from, loc to] classDependencies)
	| MethodLevelDependencyInfo(rel[loc from, loc to] classDependencies); 

//TODO: needed for visualization
data PackageInfoType = PackageInfo(
  loc location,
  str name,
  int LOC,
  Rank complexityRank,
  list[ClassInfoType] classes,
  DependencyInfo classDependency
);

//TODO: needed for visualization
data ClassInfoType = ClassInfo(
  loc location,
  str name,
  int LOC,
  Rank complexityRank,
  list[MethodInfoType] methods,
  DependencyInfo methodDependency
);

//TODO: needed for visualization
data VisualizationDataType = VisualizationData(
  loc project,
  list[PackageInfoType] packages,
  //TODO: use a list like above, or a map like below?
  map[loc location, PackageInfoType info] packages2,
  DependencyInfo packageDependency
);