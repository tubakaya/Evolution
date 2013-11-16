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
   	 "Complexity": GetComplexityRank(project, projectType)
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
  result = ExtractCC(project, projectType);
  //println("result: <result>");
  return Moderate(0);
}