module FactExtractors::ExtractorCommon

import util::FileSystem;
import IO;
import String;
/*import lang::java::jdt::m3::AST;
* Need this import for GetAllMethods
*/

list[loc] GetAllFiles(loc project, str ext)
{
	return [f | /file(f) <- crawl(project), f.extension == ext];
}

list[str] GetCodeLines(loc location)
{
	list[str] allLines = readFileLines(location);
	return codeLines = [l | l <- allLines
					, !isEmpty(trim(l))
					, !startsWith(trim(l),"//")
					, !startsWith(trim(l),"/*")
					, !startsWith(trim(l),"*")
					, !endsWith(trim(l),"*/")];
}

list[loc] GetAllMethods(loc project)
{
	/*Get here all the methods using m3*/	
	return [];
}
