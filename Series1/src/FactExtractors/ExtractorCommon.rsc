@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module FactExtractors::ExtractorCommon

import IO;
import String;
import util::FileSystem;
import Utils;
import List;


public int GetLOC(loc location)
{
  return size(GetCodeLines(location));
}


//TODO: Currently this function is called two times for every piece
//      of source code:
//        1) from ExtractTotalLOC() for all files
//        2) from ExtractMethodInfo() for all methods
//      Not optimal!! 
public list[str] GetCodeLines(loc location)
{
  list[str] allLines = readFileLines(location);
 
  list[str] result = [];
  inComment = false;
  
  for(s <- allLines) {
    // remove multi-line comments: /* ... */
    <inComment, s> = removeComments(inComment, s);

    // remove single-line comments: //...
    i = findFirst(s, "//");
    if (i != -1) {
      s = s[..i];
    }

    // trim line
    s = trim(s);

    // remove lines with only opening bracket: '{'
    s = s == "{" ? "" : s;
      
    // remove lines with only closing bracket: '}'
    s = s == "}" ? "" : s;
      
    if (!isEmpty(s)) {
      result += s;
    }
  }

  return result;
}


tuple[bool inComment, str s] removeComments(bool inComment, str line) {
  commentStart = findFirst(line, "/*");
  commentEnd = findFirst(line, "*/");
  
  if (inComment) {
    // already inside comment
    if (commentEnd != -1) {
      // end comment found, return line after comment end
      return <false, substring(line, commentEnd+2)>;
    } else {
      // no end comment found, return empty line (skip this line)
      return <true, "">;
    }
  } else {
    // not inside comment
    if (commentStart != -1) {
      // start comment found 
      if (commentEnd != -1) {
        commentEnd += 0;
        // end comment found, return line without comment
        return <false, substring(line, 0, commentStart) + substring(line, commentEnd+2)>;
      } else {
        // no end comment found, return line before comment start 
        return <true, substring(line, 0, commentStart)>;
      }
    }
  }
  
  return <false, line>;  
}


public list[loc] GetAllFiles(loc project, str ext)
{
   // skip all files containing 'junit' in location
   return [f | /file(f) <- crawl(project), f.extension == ext, /junit/ !:= f.path];
}