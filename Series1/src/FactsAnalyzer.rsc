module FactsAnalyzer
import Ranking;

map[str,int] LOCRatio = ("java":66, "Cobol":131);

/*Volume ranking is calculated so:
Function point per language is calculated and you can see this from LOCRatio above.
Total lines of code divided by 1000 gives total KLOC.
In Java language, 
0-66KLOC is ranked as VeryHigh,
66-246KLOC is ranked as High,
246-665KLOC is ranked as Moderate,
655-1,310KLOC is ranked as Low,
>1,310KLOC is ranked as VeryLow */
public Rank AnalyzeVolume(int LOC, str ext)
{
	int ratio=[ LOCRatio[k] | k <- LOCRatio, k==ext ][0];
	num kloc= LOC/1000;
	
if(kloc<66)
{
return VeryHigh(kloc);
}
	else
	{
	return High(kloc);
	}
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