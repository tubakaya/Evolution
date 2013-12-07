@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module VisualizationData

import IO;
import lang::json::IO;

import FactExtractors::ExtractorCommon;
import FactExtractors::MethodInfoExtractor;
import FactExtractors::TotalLOCExtractor;
import Utils;
import Types;

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

  writeTextJSonFile(file, facts); 
}