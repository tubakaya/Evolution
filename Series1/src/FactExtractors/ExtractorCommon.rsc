module FactExtractors::ExtractorCommon

import IO;
import String;
import util::FileSystem;

import FactsType;

public list[loc] GetAllFiles(loc project, str ext)
{
        return [f | /file(f) <- crawl(project), f.extension == ext];
}

public list[str] GetCodeLines(loc location)
{
        list[str] allLines = readFileLines(location);
        return codeLines = [l | l <- allLines
                                        , !isEmpty(trim(l))
                                        , !startsWith(trim(l),"//")
                                        , !startsWith(trim(l),"/*")
                                        , !startsWith(trim(l),"*")
                                        , !endsWith(trim(l),"*/")];
}