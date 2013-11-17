module Ranking

data ExtractedData = Single(num extVal)
 |Multiple(num extVal1, num extVal2, num extVal3);

data Rank = VeryLow(ExtractedData extData)
|Low(ExtractedData extData)
|Moderate(ExtractedData extData)
|High(ExtractedData extData)
|VeryHigh(ExtractedData extData);