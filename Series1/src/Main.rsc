module Main
import MaintainabilityAnalyzer;
import Ranking;

public map[str,Rank] Main()
{
	/*loc project=|project://TestJ|;*/
	loc project=|project://SmallSql|;
	str projectType="java";

	return AnalyzeMaintainability(project,projectType);

	/*change the return type to void and visualize results	
	for( (s:r) <- result)
	{
		println("<s> rank is <r==VeryHigh?"VeryHigh">");
	}*/
}