module FactExtractors::ExtractorCommon
import lang::java::jdt::m3::Core;
import lang::java::\syntax::Java15;
import util::FileSystem;
import IO;
import String;
import ParseTree;

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
