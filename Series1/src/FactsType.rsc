module FactsType

data MethodInfoType = MethodInfo(loc method, int LOC, int complexity);

data FactsType = Facts(
  loc project,
  str ext,
  list[MethodInfoType] methods,
  int totalLOC,
  int duplicateCount
);
