module FactsAnalyzer

import FactsType;
import Ranking;
import Utils;

import util::Math;
import List;

/*
  Volume ranking is calculated so:
    Function point per language is calculated and you can see this from LOCRatio above.
    Total lines of code divided by 1000 gives total KLOC.
  
  In Java language, 
      0-66    KLOC is ranked as VeryHigh,
     66-246   KLOC is ranked as High,
    246-665   KLOC is ranked as Moderate,
    655-1,310 KLOC is ranked as Low,
       >1,310 KLOC is ranked as VeryLow
*/
public Rank AnalyzeVolume(FactsType facts)
{
  num kloc = facts.totalLOC/1000;
	
  return if (kloc < 66) {
    VeryHigh(kloc);
  } else if (kloc < 246) {
    High(kloc);
  } else if (kloc < 665) {
    Moderate(kloc);
  } else if (kloc < 1310) {
    Low(kloc);
  } else {
    VeryLow(kloc);
  }
}


data RiskLevel = riskLevel(
  int LOC, int percentage
);

data RiskLevels = riskLevels(
  RiskLevel low,
  RiskLevel moderate,
  RiskLevel high,
  RiskLevel veryhigh
);

data RiskEvaluation = riskEvaluation(
  int lowBoundary,
  int moderateBoundary,
  int highBoundary
);

RiskLevels calcRiskLevels(
  FactsType facts,
  RiskEvaluation evaluation,
  bool (MethodInfoType m, int boundary) compareFunc
) {
  RiskLevels risks = riskLevels(riskLevel(0,0), riskLevel(0,0), riskLevel(0,0), riskLevel(0,0));

  for(m <- facts.methods) {
    if (compareFunc(m, evaluation.lowBoundary)) {
      risks.low.LOC += m.LOC;
    } else if (compareFunc(m, evaluation.moderateBoundary)) {
      risks.moderate.LOC += m.LOC;
    } else if (compareFunc(m, evaluation.highBoundary)) {
      risks.high.LOC += m.LOC;
    } else {
      risks.veryhigh.LOC += m.LOC;
    }
  }
  // calculate percentages, to avoid rounding errors we calculate the last
  // percentage as the remainder of 100%
  risks.low.percentage = percentage(risks.low.LOC, facts.totalLOC);
  risks.moderate.percentage = percentage(risks.moderate.LOC, facts.totalLOC);
  risks.high.percentage = percentage(risks.high.LOC, facts.totalLOC);
  risks.veryhigh.percentage = 100 - risks.high.percentage - risks.moderate.percentage - risks.low.percentage;
  
  return risks;
}


//TODO: make footprints a list with Rank as a part of tuple
data Footprint = footprint(
  tuple[int moderate, int high, int veryhigh] veryhigh,
  tuple[int moderate, int high, int veryhigh] high,
  tuple[int moderate, int high, int veryhigh] moderate,
  tuple[int moderate, int high, int veryhigh] low
);   

Rank calcRating(RiskLevels risks, Footprint fp) {
  result = VeryLow(0);

  if (
      (risks.moderate.percentage <= fp.veryhigh.moderate) &&
      (risks.high.percentage <= fp.veryhigh.high) &&
      (risks.veryhigh.percentage <= fp.veryhigh.veryhigh)) {
    result = VeryHigh(0);
  } else if (
      (risks.moderate.percentage <= fp.high.moderate) &&
      (risks.high.percentage <= fp.high.high) &&
      (risks.veryhigh.percentage <= fp.high.veryhigh)) {
    result = High(0);
  } else if (
      (risks.moderate.percentage <= fp.moderate.moderate) &&
      (risks.high.percentage <= fp.moderate.high) &&
      (risks.veryhigh.percentage <= fp.moderate.veryhigh)) {
    result = Moderate(0);
  } else if (
      (risks.moderate.percentage <= fp.low.moderate) &&
      (risks.high.percentage <= fp.low.high) &&
      (risks.veryhigh.percentage <= fp.low.veryhigh)) {
    result = Low(0);
  }

  return result;
}


public Rank AnalyzeComplexity(FactsType facts)
{
  /*
  	Calculations based on "A Practical Model for Measuring Maintainability",
    Ilja Heitlager, Tobias Kuipers, Joost Visser,
    http://homepages.cwi.nl/~jurgenv/teaching/evolution1213/papers/SMMQuatic.pdf

    For all methods
      calculate it's risk evaluation based on:
		CC		Risk evaluation
		1 -10	simple, low risk
		11-20	more complex, moderate risk
		21-50	complex, high risk
		  >50	untestable, very high risk
		
	  for each risk evaluation aggregate the number of lines
	  as percentage to LOC
  */
  risks = calcRiskLevels(
    facts,
    riskEvaluation(10, 20, 50),
    bool (MethodInfoType m, int boundary) {
      return (m.complexity <= boundary);
    }
  ); 
  /*debug*/ debug("== AnalyzeComplexity: risks = <risks>");


  /*
	Determine ranking based on:
			maximum relative LOC
	rank	moderate	high	very high
	++		25%			0%		0%
	+		30%			5%		0%
	o		40%			10%		0%
	-		50%			15%		5%
	--		-			-		-	  
  */
  Footprint fp = footprint(
    <25,  0, 0>,
    <30,  5, 0>,
    <40, 10, 0>,
    <50, 15, 5>
  );
  return calcRating(risks, fp);
}


public Rank AnalyzeUnitSize(FactsType facts)
{
  /*
  	In "A Practical Model for Measuring Maintainability" no thresholds are
  	given what is considerd to be a 'good' unit size.
  	It is stated to use scoring guidelines from Complexity per unit,
  	but with different (non specified) threshold values.
  	
  	To get some reasonable thresholds we use research data from
  	  Code Complete, 2003, Steven C. McConnell, chapter 7.4
  	
  	For risk evaluation categorization the following threshold values are used:   
		LOC		Risk evaluation
		1  -10	simple, low risk 
		11 -100	more complex, moderate risk
		101-200	complex, high risk
		   >200	untestable, very high risk
		
	Then again calculate the number of lines as percentage to LOC.
  */
  risks = calcRiskLevels(
    facts,
    riskEvaluation(10, 100, 200),
    bool (MethodInfoType m, int boundary) {
      return (m.LOC <= boundary);
    }
  ); 
  /*debug*/ debug("== AnalyzeUnitSize: risks = <risks>");

  /*
  	The ranking is based on the following thresholds (same as complexity):
				maximum relative LOC
		rank	moderate	high	very high
		++		25%			0%		0%
		+		30%			5%		0%
		o		40%			10%		0%
		-		50%			15%		5%
		--		-			-		-	  
  */
  Footprint fp = footprint(
    <25,  0, 0>,
    <30,  5, 0>,
    <40, 10, 0>,
    <50, 15, 5>
  );
  return calcRating(risks, fp);
}


/*
  Find the percentage of duplicated code to the whole project.
  Ranking is so:
    0-3% VeryHigh
    3-5% High
    5-10% Moderate
    10-20% Low
    20-100% Very Low
*/
public Rank AnalyzeDuplication(FactsType facts)
{
  //TODO: implement
  return Low(0);
}


public Rank AnalyzeAssertion(FactsType facts)
{
  /*
    The following code is based on findings reported in 
      Assessing the Relationship between Software Assertions and Code Quality:
      An Empirical Investigation", Gunnar Kudrjavets, Nachiappan Nagappan,
      Thomas Ball, Microsoft
      http://research.microsoft.com/pubs/70290/tr-2006-54.pdf
     
    See also
      http://research.microsoft.com/en-us/news/features/nagappan-100609.aspx


    They observed a negative correlation: more assertions and code
    verifications means fewer bugs.
    In the paper assertion density is defined as 'number of assertions / KLOC'.
    However, they don't present thresholds to base a ranking on for which
    assertion density is suppost to be low, moderate or high.  
     
    The metric implemented in this function uses some 'common sense' values
    for ranking the number of "assertions per method". Assertion density
    is not used because we believe the number of assertions depends should be
    per method and depending on the number of arguments (not implemented right
    now).
    Assertion density (per KLOC or method) is something that could/should be
    researched more (thesis subject??).   

    For all methods
      calculate it's assertion density based on:
		AD		Risk evaluation
		0-0		very high risk
		1-1		high risk
		2-4		moderate risk
		 >4		low risk
		
	  for each risk evaluation aggregate the number of lines
	  as percentage to LOC
 
  	Determine ranking based on:
			maximum relative LOC
	  rank	moderate	high	very high
	  ++	25%			0%		0%
	  +		30%			5%		0%
	  o		40%			10%		0%
	  -		50%			15%		5%
	  --		-			-		-	  
  */
  risks = calcRiskLevels(
    facts,
    riskEvaluation(0, 1, 4),
    bool (MethodInfoType m, int boundary) {
      return (m.assertCount <= boundary);
    }
  ); 
  /*debug*/ debug("== AnalyzeAssertion: risks = <risks>");

  Footprint fp = footprint(
    <25,  0, 0>,
    <30,  5, 0>,
    <40, 10, 0>,
    <50, 15, 5>
  );
  return calcRating(risks, fp);
}
