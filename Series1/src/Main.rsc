module Main

import MaintainabilityAnalyzer;
import Ranking;
import Utils;

public map[str, Rank] Main()
{
  loc project = |project://TestJ|;
  //loc project = |project://SmallSql|;
  //loc project = |project://QLJava|;
  str projectType = "java";

  result = AnalyzeMaintainability(project, projectType);
  
  return result;
}
