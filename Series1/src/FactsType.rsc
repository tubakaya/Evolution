@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module FactsType

data MethodInfoType = MethodInfo(
  loc method,
  int LOC,
  int complexity,
  int assertCount
);

data FactsType = Facts(
  loc project,
  str ext,
  list[MethodInfoType] methods,
  int totalLOC,
  int duplicateCount
);