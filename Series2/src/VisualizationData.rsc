@contributor{Sander Leer - Sander.Leer@gmail.com}
@contributor{Tuba Kaya Chomette - tuba_kaya@outlook.com}

module VisualizationData

import IO;
import DateTime;
import lang::json::IO;
//import lang::html5::DOM;
import util::Editors;
import util::Webserver;

import Utils;
import Types;
import DependencyExtractor;


public void writeFacts() {
  //loc project = |project://TestJ|;
  loc project = |project://SmallSql|;
  //loc project = |project://hsqldb|;

  // extract all facts from source code
  facts = ExtractClassDependencies(project);
  
  loc file = |home:///Desktop/tempFacts.txt|;
  writeTextJSonFile(file, facts); 
}



str getInfo(map[str,str] parameters) {
  s = parameters["loc"];
    
  return
    "\<h1\>Hallo\</h1\>
    '  Het is \<b\>nu\</b\> <now()>. \</br\>
    '  Parameters: \</br\>
    '  <parameters> \</br\>
    '  \</br\>
    '  loc = <s>
    ";
}

str showLocation(map[str,str] parameters) {
  edit(|project://TestJ/src/Extra.java|(1162,175,<49,1>,<57,2>));
  return getInfo();
}


loc SERVER  = |http://localhost:8080|;
loc WEBROOT = |home:///Desktop/|;

public void webStart() {
  //serve(SERVER, fileserver(WEBROOT));
  serve(SERVER, functionserver((
      "/": getInfo
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
