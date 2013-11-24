module Main

import MaintainabilityAnalyzer;
import Ranking;
import Utils;

import util::Benchmark;

public map[str, Rank] Main()
{
  loc project = |project://TestJ|;
  //loc project = |project://SmallSql|;
  str projectType = "java";

  map[str, Rank] result;
  time = realTime(void() {
    result = AnalyzeMaintainability(project, projectType);
  });
  debug("== real time: <time/1000.0> seconds");
  
  return result;
}
