module Main
import MaintainabilityAnalyzer;
import Ranking;

public void Main()
{
loc project=|project://TestJ|;
str projectType="java";

map[str,Rank] result = AnalyzeMaintainability(project,projectType);

/*print results
for( (s:r) <- result)
{
	println("<s> rank is <r==VeryHigh?"VeryHigh">");
}*/
}