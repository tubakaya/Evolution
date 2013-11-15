module FactsAnalyzer

map[str,int] LOCRatio = ("java":66, "Cobol":131);


public int AnalyzeVolume(int LOC, str ext)
{
	int ratio=[ LOCRatio[k] | k <- LOCRatio, k==ext ][0];
	num kloc= LOC/1000;
	return 1;
}