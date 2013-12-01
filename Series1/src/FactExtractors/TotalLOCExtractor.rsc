@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module FactExtractors::TotalLOCExtractor

import FactExtractors::ExtractorCommon;
import Utils;

import List;
import util::Math;

/*
  Extracts only code lines
*/
public int ExtractTotalLOC(list[loc] allFiles)
{
  /*debug*/ debug("extracting total LOC...");
  /*debug*/ int totalFiles = size(allFiles);
  /*debug*/ debug("\ttotal files = <totalFiles>");
  /*debug*/ int i = 1;

  list[int] result = [];
  for(f <- allFiles) {
    /*debug*/ debug("\t<i>/<totalFiles>: <f>");
    /*debug*/ i += 1;
    result += GetLOC(f);
  }

  return toInt(sum(result));
}