module CC::CCAnalyzer
import Types;

//From Series1
import Utils;

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

public int AnalyzeComplexity(ClassFacts facts)
{
  risks = calcRiskLevels(
    facts,
    riskEvaluation(10, 20, 50),
    int (MethodInfo m) { return m.complexity; }
  ); 

  Footprint fp = footprint(
    <25,  0, 0>,
    <30,  5, 0>,
    <40, 10, 0>,
    <50, 15, 5>
  );
  return calcRating(risks, fp);
}

RiskLevels calcRiskLevels(
  ClassFacts facts,
  RiskEvaluation evaluation,
  int (MethodInfo mi) getField
) {
  RiskLevels risks = riskLevels(riskLevel(0,0), riskLevel(0,0),
    riskLevel(0,0), riskLevel(0,0));

  for(m <- facts.methods) {
    if (getField(m) <= evaluation.lowBoundary) {
      risks.low.LOC += m.LOC;
    } else if (getField(m) <= evaluation.moderateBoundary) {
      risks.moderate.LOC += m.LOC;
    } else if (getField(m) <= evaluation.highBoundary) {
      risks.high.LOC += m.LOC;
    } else {
      risks.veryhigh.LOC += m.LOC;
    }
  }
  // calculate percentages, to avoid rounding errors calculate the last
  // percentage as the remainder of 100%
  risks.low.percentage = percentage(risks.low.LOC, facts.totalLOC);
  risks.moderate.percentage = percentage(risks.moderate.LOC, facts.totalLOC);
  risks.high.percentage = percentage(risks.high.LOC, facts.totalLOC);
  risks.veryhigh.percentage = 100 - risks.high.percentage -
    risks.moderate.percentage - risks.low.percentage;
  
  return risks;
}


//TODO: make footprints a list with Rank as a part of tuple
data Footprint = footprint(
  tuple[int moderate, int high, int veryhigh] veryhigh,
  tuple[int moderate, int high, int veryhigh] high,
  tuple[int moderate, int high, int veryhigh] moderate,
  tuple[int moderate, int high, int veryhigh] low
);   

int calcRating(RiskLevels risks, Footprint fp) {
  result = 1;

  if (
      (risks.moderate.percentage <= fp.veryhigh.moderate) &&
      (risks.high.percentage <= fp.veryhigh.high) &&
      (risks.veryhigh.percentage <= fp.veryhigh.veryhigh)) {
    result = 5;
  } else if (
      (risks.moderate.percentage <= fp.high.moderate) &&
      (risks.high.percentage <= fp.high.high) &&
      (risks.veryhigh.percentage <= fp.high.veryhigh)) {
    result = 4;
  } else if (
      (risks.moderate.percentage <= fp.moderate.moderate) &&
      (risks.high.percentage <= fp.moderate.high) &&
      (risks.veryhigh.percentage <= fp.moderate.veryhigh)) {
    result = 3;
  } else if (
      (risks.moderate.percentage <= fp.low.moderate) &&
      (risks.high.percentage <= fp.low.high) &&
      (risks.veryhigh.percentage <= fp.low.veryhigh)) {
    result = 2;
  }

  return result;
}