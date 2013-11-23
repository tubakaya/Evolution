module MaintainabilityAnalyzer

import FactExtractors::ComplexityExtractor;
import FactExtractors::DuplicationCountExtractor;
import FactExtractors::TotalLOCExtractor;
import FactExtractors::UnitSizeExtractor;
import FactsAnalyzer;
import Ranking;
import Utils;

/*
  TODO:
    For a more efficient version we should first run all the ExtractXXX functions,
    the gathered facts can then be re-used by other ExtractXXX and AnalyzeXXX functions.
    Proposal is to make a data structure containing the following information and
    pass it to each ExtractXXX and AnalyzeXXX funtion.
    
    For example:
      data MethodInfo = methodInfo(loc method, int complexity, int LOC);
      data Facts = facts(
        int totalLOC, 
        list[MethodInfo] methods,
        ... information for duplication...
      );
    
    Then each call to the ExtractXXX and AnalyzeXXX functions could be like:
      Facts facts;
      facts = ExtractTotalLOC(facts);
      facts = ExtractComplexity(facts);
      ...
      
      rank = AnalyzeVolume(facts);
      rank = AnalyzeComplexity(facts);
      ...
*/ 


/*
  Calls analyze methods in FactsAnalyzer to find the rankings for the
  volume, cyclometic complexity, duplication, unit size and unit testing.
  Returns a map with the name of the metric and the rank.
*/
public map[str, Rank] AnalyzeMaintainability(loc project, str projectType)
{
  /* call analyze methods and add findings to the result */
  map[str, Rank] result = (
	 "Volume": GetVolumeRank(project, projectType),
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
  debug("====== GetComplexityRank");
  for(f <- facts) debug("CC: <f.CC>\tlines: <f.lines>\t<f.method>");
  debug("======");
  
  //TODO: it is not optimal te extractTotalLOC again, gather general facts about
  //      the project instead of re-calculating it again
  totalLOC = ExtractTotalLOC(project, projectType);
  result = AnalyzeComplexity(totalLOC, facts);

  return result;
}

Rank GetDuplicationRank(loc project, str projectType)
{
  //TODO: implement
  return VeryLow(0);
}

Rank GetUnitSizeRank(loc project, str projectType)
{
  facts = ExtractUnitSizes(project, projectType);
  debug("====== GetUnitSizeRank");
  debug("facts: <facts>");
  debug("======");
  
  result = AnalyzeUnitSize(facts);
  
  return result;
}