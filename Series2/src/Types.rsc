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