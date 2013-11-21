module Main

import MaintainabilityAnalyzer;
import Ranking;
import Utils;

public map[str, Rank] Main()
{
  loc project=|project://TestJ|;
  //loc project=|project://SmallSql|;
  str projectType="java";

  result = AnalyzeMaintainability(project, projectType);
  
  return result;

	  /*change the return type to void and visualize results	
	  for( (s:r) <- result)
	  {
		    println("<s> rank is <r==VeryHigh?"VeryHigh">");
	  }*/
}
