module IO::FileWriter

import String;
import IO;
import List;

import Types;
import Utils;

public void WriteClassAndFileNamesToJson(map[loc location,str fileName] classFileNames)
{
	str text="{\"classes\": [";
		
	for(c <- classFileNames)
	{		
		text += "\"<classFileNames[c]>\",";
	}
	text = substring(text,0,size(text)-1);
	text+="]}";
	 
	loc file = |home:///Desktop/Series2/classFileNames.json|;
  	writeFile(file, text); 
  	debug("Wrote classFileNames into a json file");	
}

public void WriteJsonForClassDependencyTree(str fileName, DependencyTree dependencyTree)
{	
	str text="{";
	text+= "\"name\": \"<dependencyTree.name>\",";
	text+= "\"params\": {";
		text+="\"location\": \"<dependencyTree.params.location>\",";
		text+="\"LOC\": <dependencyTree.params.LOC>,";
		text+="\"CC\": <dependencyTree.params.CC>";
	text+="},";
	text+="\"children\": [";			
	for(c <- dependencyTree.children)
	{
		text+=GetTextForChild(c);
	}
	if(size(dependencyTree.children)>0)
	{
		text = substring(text,0,size(text)-1);
	}
	text+="]}";
	 
	loc file = |home:///Desktop/Series2/<fileName>.json|;
  	writeFile(file, text); 
}

public str GetTextForChild(DependencyTree dependencyTree)
{
	str text = "{";
	text+= "\"name\": \"<dependencyTree.name>\",";
	text+= "\"params\": {";
		text+="\"location\": \"<dependencyTree.params.location>\",";
		text+="\"LOC\": <dependencyTree.params.LOC>,";
		text+="\"CC\": <dependencyTree.params.CC>,";
		text+="\"dependencyCount\": <dependencyTree.params.dependencyCount>";
	text+="},";
	text+="\"children\": [";
	if(size(dependencyTree.children)>0)
	{
		for(dc<-dependencyTree.children)
		{
			text+=GetTextForChild(dc);
		}
		text = substring(text,0,size(text)-1);
	}

	text+="]},";
	return text;
}
