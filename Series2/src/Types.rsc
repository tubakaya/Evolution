module Types

import Ranking;
import FactsType;

data ClassInfo = ClassInfo(
  loc location,
  str name,
  int LOC,
  Rank CC,
  map[loc depOn, int count] dependencies
);

data VisualizationData = VisualizationData(
  list[ClassInfo] classes
);