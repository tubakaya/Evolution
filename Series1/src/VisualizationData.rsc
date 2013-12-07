@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module VisualizationData

import IO;
import lang::json::IO;

import Ranking;
import FactsType;
import FactExtractors::ExtractorCommon;
import FactExtractors::MethodInfoExtractor;
import FactExtractors::TotalLOCExtractor;
import Utils;

//TODO: needed for visualization
data DependencyInfoType = DependencyInfo(
  rel[loc from, loc to, int weigth] edge
); 

//TODO: needed for visualization
data PackageInfoType = PackageInfo(
  loc location,
  str name,
  int LOC,
  Rank complexityRank,
  list[ClassInfoType] classes,
  DependencyInfoType classDependency
);

//TODO: needed for visualization
data ClassInfoType = ClassInfo(
  loc location,
  str name,
  int LOC,
  Rank complexityRank,
  list[MethodInfoType] methods,
  DependencyInfoType methodDependency
);

//TODO: needed for visualization
data VisualizationDataType = VisualizationData(
  loc project,
  list[PackageInfoType] packages,
  //TODO: use a list like above, or a map like below?
  map[loc location, PackageInfoType info] packages2,
  DependencyInfoType packageDependency
);



public void writeFacts() {
  loc project = |project://TestJ|;
  //loc project = |project://SmallSql|;
  //loc project = |project://hsqldb|;
  str ext = "java";

  // extract all facts from source code
  FactsType facts = Facts(project, ext, [], 0, 0);
  list[loc] allFiles = GetAllFiles(project,ext);
  facts.totalLOC = ExtractTotalLOC(allFiles);
  facts.methods = ExtractMethodInfo(project, allFiles);


  
  loc file = |home:///Desktop/tempFacts.txt|;

  //writeFile(file, "Hallo");
  writeTextJSonFile(file, facts);

  
}