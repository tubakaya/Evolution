@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - admin@tubakaya.com}

module FactExtractors::TotalLOCExtractor

import FactExtractors::ExtractorCommon;

import List;

/*
  Extracts only code lines
*/
public int ExtractTotalLOC(list[loc] allFiles)
{
        list[list[str]] codeLines = [GetCodeLines(f) | f <- allFiles ];
        
        int counter = 0;
        for( i <- [0..size(codeLines)])
        {
                counter += size(codeLines[i]);
        }
        
        return counter;
}