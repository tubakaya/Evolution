module MaintainabilityAnalyzer

import FactsType;
import FactsAnalyzer;
import Ranking;
import Utils;
import FactExtractors::MethodInfoExtractor;
import FactExtractors::DuplicationCountExtractor;
import FactExtractors::TotalLOCExtractor;

/*
  First extract all facts from the source code by the ExtractXXX functions.
  Then all facts are analyzed by the AnaylzeXXX functions who determine the
  ranking for the metrics.
*/
public map[str, Rank] AnalyzeMaintainability(loc project, str ext)
{
  // extract all facts from source code
  FactsType facts = Facts(project, ext, [], 0, 0);
  facts.totalLOC = ExtractTotalLOC(project, ext);
  facts.methods = ExtractMethodInfo(project, ext);
  //facts.duplicateCount = ExtractDuplicateCount(GetAllFiles(project,ext));

  // analyze facts  
  result = (
      "Volume": AnalyzeVolume(facts)
    , "Complexity": AnalyzeComplexity(facts)
    , "Duplication": AnalyzeDuplication(facts)
    , "Unit size": AnalyzeUnitSize(facts)
    , "Assertion": AnalyzeAssertion(facts)
  );
  
  return result;
}
