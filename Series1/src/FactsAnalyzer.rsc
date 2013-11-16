module FactsAnalyzer
import Ranking;
import lang::java::\syntax::Java15;


/*It would be nicer if we had a map[Expr,Rank]
map[int, Rank] JavaLocRank = 
   ( 66  : VeryHigh
	,246 : High
	,665 : Moderate
	,1310: Low);*/


/*Volume ranking is calculated so:
Function point per language is calculated and you can see this from LOCRatio above.
Total lines of code divided by 1000 gives total KLOC.
In Java language, 
0-66KLOC is ranked as VeryHigh,
66-246KLOC is ranked as High,
246-665KLOC is ranked as Moderate,
655-1,310KLOC is ranked as Low,
>1,310KLOC is ranked as VeryLow */
public Rank AnalyzeVolume(int LOC)
{
	num kloc = LOC/1000;
	
	return if(kloc<66)
	{
	 VeryHigh(kloc);
	}
	else if(kloc<246)
	{
	 High(kloc);
	}
	else if(kloc<665)
	{
	 Moderate(kloc);
	}
	else if(kloc<1310)
	{
	 Low(kloc);
	}
	else
	{
	 VeryLow(kloc);
	}
	
	/*list[int] limits = [jr | jr <- JavaLocRank];
	for( i<-limits)
	{
		if(kloc<i)
		{
			Rank rank = JavaLocRank[i];
			return rank(kloc);
		}
	}*/
}

public Rank AnalyzeComplexity()
{
/*
  parameter:
  	map[loc method, tuple[int cc, int lines]]
  	
  todo:
    for all methods (loc)
      calculate it's risk evaluation based on:
		CC		Risk evaluation
		1-10	simple, without much risk
		11-20	more complex, moderate risk
		21-50	complex, high risk
		> 50	untestable, very high risk
		
	  for each risk evaluation calculate the number of lines
	  as percentage to LOC
	  
	  determine ranking based on:
				maximum relative LOC
		rank	moderate	high	very high
		++		25%			0%		0%
		+		30%			5%		0%
		o		40%			10%		0%
		-		50%			15%		5%
		--		-			-		-	  
*/
}

/*Find the percentage of dublicated code to the whole project.
Ranking is so:
0-3% VeryHigh
3-5% High
5-10% Moderate
10-20% Low
20-100% Very Low*/
public Rank AnalyzeDublication(int amountOfDublication)
{
}

public Rank AnalyzeUnitSize()
{}

public Rank AnalyzeUnitTesting()
{}