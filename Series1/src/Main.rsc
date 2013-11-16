module Main
import FactsExtractor;
import FactsAnalyzer;

/*Calls analyze methods in FactsAnalyzer to find the rankings
for the volume, cyclometic complexity, dublication, unit size and unit testing.
Returns a map with the name of the metric and the rank.*/
public map[str, Rank] AnalyzeMaintainability(loc project, str projectType)
{
  map[str, Rank] result;
  /*call analyze methods and add findings to the result*/
  return result;
}


public void Main()
{
loc project=|project://TestJ|;
str projectType="java";

map[str,Rank] result=AnalyzeMaintainability(project,projectType);
/*print results*/
}