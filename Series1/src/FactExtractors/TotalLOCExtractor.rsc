@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module FactExtractors::TotalLOCExtractor

import FactExtractors::ExtractorCommon;

import List;
import util::Math;

/*
  Extracts only code lines
*/
public int ExtractTotalLOC(list[loc] allFiles)
{
  return toInt(sum([GetLOC(f) | f <- allFiles ]));
}