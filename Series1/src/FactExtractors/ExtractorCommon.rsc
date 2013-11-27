@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - admin@tubakaya.com}

module FactExtractors::ExtractorCommon

import IO;
import String;
import util::FileSystem;

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

public list[loc] GetAllFiles(loc project, str ext)
{
   // skip all files containing 'junit' in location
   return [f | /file(f) <- crawl(project), f.extension == ext, !(/junit/ := f.path)];
}