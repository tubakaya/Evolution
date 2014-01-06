@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module VisualizationData

import IO;
import DateTime;
//import lang::json::IO;
//import lang::html5::DOM;
import util::Editors;
import util::Webserver;

import Utils;
import Types;
import String;
//import DependencyExtractor;


/*
public void writeFacts() {
  loc project = |project://TestJ|;
  //loc project = |project://SmallSql|;
  //loc project = |project://hsqldb|;

  // extract all facts from source code
  facts = ExtractClassDependencies(project);
  
  loc file = |home:///Desktop/tempFacts.txt|;
  writeTextJSonFile(file, facts); 
}
*/


str getServerInfo(map[str,str] parameters) {
  return "Rascal webserver running..."; 
}

str LOC_PARAMETER = "loc";

str getInfo(map[str,str] parameters) {
  debug("getInfo");
  
  loc location = toLocation("");
  if (LOC_PARAMETER in parameters) {
    location = toLocation(parameters[LOC_PARAMETER]);
  }

  return
    "\<h1\>Hallo\</h1\>
    '  Het is \<b\>nu\</b\> <now()>.\</br\>
    '  \</br\>
    '  Parameters: \</br\>
    '  <parameters> \</br\>
    '  \</br\>
    '  loc = <location>
    ";
}

str showLocation(map[str,str] parameters) {
  debug("showLocation");
  
  if (LOC_PARAMETER in parameters) {
    loc location = toLocation(parameters[LOC_PARAMETER]);
    //edit(|project://TestJ/src/Extra.java|(1162,175,<49,1>,<57,2>));
    debug("\tgoing to editor on <location>");
    
    //TODO: this stops the execution of this function, and no http data is
    //      ever returned
    edit(location);
  }

  return "";
}

loc SERVER  = |http://localhost:8080|;
loc WEBROOT = |home:///Desktop/|;

public void webStart() {
  //serve(SERVER, fileserver(WEBROOT));
  serve(SERVER, functionserver((
      "/": getServerInfo
    , "/getInfo": getInfo
    , "/showLocation": showLocation
  )));


  //TODO: it seems to be needed to wait 10 seconds; why?
  //      it looks like the first request has to be served within this timeframe
  //      and is there no sleep() function to avoid busy waiting?
  t0 = incrementSeconds(now(), 15);
  while(t0 > now()) {
    debug("<now()>");
  }
}

public void webStop() {
  shutdown(SERVER);
}
