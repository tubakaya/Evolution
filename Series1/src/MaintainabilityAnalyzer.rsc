module MaintainabilityAnalyzer

import IO;

import FactsExtractor;
import FactsAnalyzer;
import Ranking;

/*Calls analyze methods in FactsAnalyzer to find the rankings
for the volume, cyclometic complexity, dublication, unit size and unit testing.
Returns a map with the name of the metric and the rank.*/
public map[str, Rank] AnalyzeMaintainability(loc project, str projectType)
{
  /*call analyze methods and add findings to the result*/
  map[str, Rank] result = (
	 "Volume": GetVolumeRank(project,projectType),
   	 "Complexity": GetComplexityRank(project, projectType),
   	 "Duplication": GetDuplicationRank(project, projectType),
   	 "Unit size": GetUnitSizeRank(project, projectType)
  );
    
  return result;
}

Rank GetVolumeRank(loc project, str projectType)
{
  int totalLOC = ExtractTotalLOC(project,projectType);
  return AnalyzeVolume(totalLOC);
}

Rank GetComplexityRank(loc project, str projectType)
{
  facts = ExtractComplexity(project, projectType);
  //println("======");
  //for(f <- facts) {
  //  println("CC: <f.CC>\tlines: <f.lines>\t<f.method>");
  //}
  //println("======");
  
  result = AnalyzeComplexity(facts);

  return result;
}

Rank GetDuplicationRank(loc project, str projectType)
{
  //TODO: implement
  return Moderate(0);
}

Rank GetUnitSizeRank(loc project, str projectType)
{
  //TODO: implement
  return Moderate(0);
}