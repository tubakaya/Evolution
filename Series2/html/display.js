//TODO:
//  - show details on hover (complete packagename, LOC, CC, etc)
//  - change colors and check for colorblindness
//  - add slider with number of levels to show


// global SVG object for graph
var svg = null

// constants used in program
var constants = {
  // the Java project for maintenance
  project: "test",
  //project: "SmallSql",
  //project: "HSqlDb",
  
  // JSON file with all classnames and widget to store them
  classnamesFile: "classFileNames",
  widgetClassnames: "#cboClassnames",

  // location and information about JSON files
//  JSONpath: "/json/SmallSql/",
  JSONpath: "/json/",
  JSONext: ".json",
  
  // test files with JSON data
  factsFile1: "test/test1",
  factsFile2: "test/test2",
  
  // Rascal webserver URL's for openening source files
  //TODO: revert
  rascalWebserverInfo: "http://localhost:8080/showLocation?loc=",
  rascalWebserver: "http://localhost:8080/getInfo?loc=",
  
  // width and height of SVG viewport
  width: 1000,
  height: 1000,

  // max levels of tree to show
  maxLevels: 5,
  
  // width and height of node box  
  boxWidth: 120,
  boxHeight: 50,

  // maximum amount of pixels a node box can grow based on ClassInfo LOC
  maxBoxGrowth: 100,
  
  // maximum stroke-width for a link between nodes, based on ClassInfo dependency count
  maxStrokeWidth: 30,
  
  // colors for showing ClassInfo cyclomatic complexity
  // We've choosen an analogous color scheme ranging from 'green' (hue 122)
  // for low CC to 'red' (hue 10) for high CC. This gives five colors with
  // hue values: 122, 70, 48, 32, 10.
  // To 'smoothen' the display values (makes them visually less 'hard')
  // decreased the saturation to 77 and brightness to 90.
  // See: http://goo.gl/aANQ1T
  colorsCC: ["#E55335", "#E59335", "#E5C235", "#C7E535", "#35E53B"],

  // See: http://goo.gl/f5Z3kq
  colorsCC: ["#F22918", "#FF8AEB", "#00C8F2", "#FFF300", "#18F230"],
  
  // colors for elements
  colorLink: "#CCC",      // color for links between nodes
  colorLinkHover: "#888",
  colorText: "#000",      // color for text in nodes
  colorTextHover: "#DDD",
  
  // times (ms) for fade-in and -out
  fadeIn: 600,
  fadeOut: 300,
  
  // factor which is used to 'brighten' the path when hovering over a node
  brightnessFactor: .2
}


// globals used in program
var globals = {
  maxLevel: Number.MIN_VALUE,
  maxSpan: Number.MIN_VALUE,
  minCC: Number.MAX_VALUE,
  maxCC: Number.MIN_VALUE,
  minLOC: Number.MAX_VALUE,
  maxLOC: Number.MIN_VALUE,
  minDepend: Number.MAX_VALUE,
  maxDepend: Number.MIN_VALUE
}

function initGlobals() {
  globals.maxLevel = Number.MIN_VALUE
  globals.maxSpan = Number.MIN_VALUE
  globals.minCC = Number.MAX_VALUE
  globals.maxCC = Number.MIN_VALUE
  globals.minLOC = Number.MAX_VALUE
  globals.maxLOC = Number.MIN_VALUE
  globals.minDepend = Number.MAX_VALUE
  globals.maxDepend = Number.MIN_VALUE
}


function makeJSONfile(filename) {
  return constants.JSONpath + constants.project + "/" + filename + constants.JSONext
}


function loadClassnames() {
  filename = makeJSONfile(constants.classnamesFile)
  console.log("loading classnames: " + filename)
  $.getJSON(filename, function(data) {
    console.log("classnames loaded: " + filename)
    $(constants.widgetClassnames).empty()
    $.each(data.classes, function(key, value) {
      $(constants.widgetClassnames).append(
        $("<option>", {value: value}).text(value)
      )
    })
  })
}


function loadFacts(filename) {
  console.log("loading facts: " + filename)
  d3.json(filename, function(error, data) {
    console.log("facts loaded: " + filename)
    createGraph(data)
  })
}


function traverse(data, level) {
  globals.maxLevel = Math.max(level, globals.maxLevel)
  if (data !== null && typeof(data) == "object") {
    globals.maxSpan = Math.max(data.children.length, globals.maxSpan)
    globals.minCC = Math.min(data.params.CC, globals.minCC)
    globals.maxCC = Math.max(data.params.CC, globals.maxCC)
    globals.minLOC = Math.min(data.params.LOC, globals.minLOC)
    globals.maxLOC = Math.max(data.params.LOC, globals.maxLOC)
    if (data.params.dependencyCount != undefined) {
      globals.minDepend = Math.min(data.params.dependencyCount, globals.minDepend)
      globals.maxDepend = Math.max(data.params.dependencyCount, globals.maxDepend)
    }
    $.each(data.children, function(key, value) {
      traverse(value, level+1)
    })
  }
}


function truncateLevel(data, truncLevel, currLevel) {
  currLevel = currLevel + 1
  if (currLevel >= truncLevel) {
    data.children = []
  } else {
    $.each(data.children, function(key, value) {
      truncateLevel(value, truncLevel, currLevel)
    })
  }
}


// create a D3 tree
function createGraph(treeData) {
  initGlobals()
  truncateLevel(treeData, constants.maxLevels, 0)
  traverse(treeData, 1)
/*
  console.log("maxLevel = " + globals.maxLevel)
  console.log("maxSpan = " + globals.maxSpan)
  console.log("minCC = " + globals.minCC)
  console.log("maxCC = " + globals.maxCC)
  console.log("minLOC = " + globals.minLOC)
  console.log("maxLOC = " + globals.maxLOC)
  console.log("minDepend = " + globals.minDepend)
  console.log("maxDepend = " + globals.maxDepend)
*/

  // remove existing (SVG) graph and create a new one
  d3.select("svg").remove()
  svg = d3.select("#graph")
    .append("svg:svg")
    .attr("width", "100%")
    .attr("height", "100%")
    .attr("viewBox", "0 0 " + constants.width + " " + constants.height)
    .append("g")
    .attr("transform", "translate(80,0)")

  var nodes = tree.nodes(treeData)
  var links = tree.links(nodes)

  // update and add links
  var existingLinks = svg.selectAll(".link").data(links)
  var newLinks = existingLinks.enter().append("path")
    .attr("class", "link")
    .attr("d", diagonal)
    .transition()
    .duration(constants.fadeIn)
  
  // update and add nodes
  var existingNodes = svg.selectAll(".node").data(nodes)
  var newNodes = existingNodes.enter().append("g")
    .attr("class", "node")
    .attr("id", getNodeID)
    .attr("transform", function(d) {
      return "translate(" + d.y + "," + d.x + ")"
    })
  newNodes.append("rect")
    .attr('class', 'nodebox')
    .attr("x", getNodeX)
    .attr("y", getNodeY)
    .attr("width", getNodeWidth)
    .attr("height", getNodeHeight)
    .attr("rx", 10)
    .attr("ry", 10)
    .style("fill", getFillColor)
  newNodes.append("text")
    .attr("class", "nodeTitle")
    .attr("y", 0)
    .attr("text-anchor", "middle")
    .text(getNodeTitle)
  newNodes.append("text")
    .attr("class", "nodeEclipse")
    .attr("y", 20)
    .attr("text-anchor", "middle")
    .attr("fill-opacity", "0.0")
    .text("Open in Eclipse")
    .on("click", nodeClick)
/*
  newNodes.append("text")
    .attr("class", "nodeText textLOC")
    .attr("y", function(d) {
      return (getNodeHeight(d) / 2) - 22
    })
    .attr("text-anchor", "middle")
    //.attr("visibility", "visible")
    //.attr("visibility", "hidden")
    .text(getNodeTextLOC)
  newNodes.append("text")
    .attr("class", "nodeText textCC")
    .attr("y", function(d) {
      return (getNodeHeight(d) / 2) - 10
    })
    .attr("text-anchor", "middle")
    .text(getNodeTextCC)
*/
  newNodes.on("mouseenter", nodeEnter)
  newNodes.on("mouseleave", nodeLeave)
  //newNodes.on("click", nodeClick)
  
  // update links after all nodes are added
  newLinks.style("stroke-width", getStrokeWidth)
}


function getNodeID(d) {
  if (d.depth == 0) {
    return "rootnode"
  }
  return "";
}

function getNodeTitle(d) {
  return d.name.length > 16 ? d.name.substring(0, 15) + "..." : d.name
}

function getNodeTextLOC(d) {
  return "LOC: " + d.params.LOC
}

function getNodeTextCC(d) {
  return "Complexity: " + d.params.CC
}

// get link stroke-width based on ClassInfo dependency count
function getStrokeWidth(d) {
  var maxDepend = globals.maxDepend
  maxDepend = maxDepend == 0 ? 1 : maxDepend
  var strokeWidth = (d.target.params.dependencyCount / maxDepend) * constants.maxStrokeWidth
  // ensure that stroke-width is at least 2
  strokeWidth = strokeWidth < 2 ? 2 : strokeWidth;
  return strokeWidth
}

// get node color based on ClassInfo Cyclomatic Complexity
function getFillColor(d) {
  return constants.colorsCC[d.params.CC-1]
}

// get node growth factor based on ClassInfo LOC
function getBoxGrowth(d) {
  return (d.params.LOC / globals.maxLOC) * constants.maxBoxGrowth
}

function getNodeWidth(d) {
  return constants.boxWidth + getBoxGrowth(d)
}

function getNodeHeight(d) {
  return constants.boxHeight + getBoxGrowth(d)
}

function getNodeX(d) {
  return -getNodeWidth(d)/2
}

function getNodeY(d) {
  return -getNodeHeight(d)/2
}

function nodeEnter(node) {
  moveText(node)
  showHyperlink(node, true)
  highlightPathToParent(node, node.depth)
}

function showHyperlink(node, show) {
  var nodeDOM = getNodeFromData(node)
  d3.select(nodeDOM).select(".nodeEclipse")
    .transition()
    .duration(constants.fadeIn)
    //.attr("visibility", show ? "visible" : "hidden")
    .attr("fill-opacity", show ? "1.0" : "0.0")
}

function moveText(node) {
  var nodeDOM = getNodeFromData(node)
  d3.select(nodeDOM).select(".nodeTitle")
    .transition()
    .duration(constants.fadeIn)
    .attr("y", -10) //-(getNodeHeight(node)/2)+25)
//    .attr("fill", constants.colorTextHover)
}

function highlightNode(nodeDOM, nodeData, brightness) {
  var col = d3.rgb(getFillColor(nodeData)).darker(constants.maxLevels*constants.brightnessFactor)
  col = d3.rgb(col).brighter(brightness*constants.brightnessFactor)
  d3.select(nodeDOM).selectAll(".nodebox")
    .transition()
    .duration(constants.fadeIn)
//    .style("fill", col.toString())
//    .style("stroke", col.toString())
    .style("stroke", "#000")
}

function highlightLink(link, brightness) {
  var col = d3.rgb(constants.colorLinkHover).brighter(brightness*constants.brightnessFactor)
  d3.select(link)
    .transition()
    .duration(constants.fadeIn)
//    .style("stroke", col.toString())
    .style("stroke", constants.colorLinkHover)

}

function highlightPathToParent(node, startDepth) {
  highlightNode(getNodeFromData(node), node, (startDepth - node.depth)*2)

  var links = getAllLinks()
  $.each(links, function(index, value) {
    if (value.__data__.target == node) {
      highlightLink(value, (startDepth - node.depth)*2+1)
      highlightPathToParent(value.__data__.source, startDepth)
    }
  })
}

function getAllLinks() {
  return svg.selectAll(".link")[0]
}

function getNodeFromData(node) {
  var nodes = d3.selectAll(".node")[0]
  var i;
  for (i = 0; i < nodes.length; ++i) {
    if (nodes[i].__data__ == node) {
      return nodes[i]
    }
  }
}

// set all visual values to defaults
function nodeLeave(node) {
  d3.selectAll(".nodebox")
    .transition()
    .duration(constants.fadeOut)
    .style("fill", getFillColor)
    .style("stroke", constants.colorLink)
  svg.selectAll(".link")
    .transition()
    .duration(constants.fadeOut)
    .style("stroke", constants.colorLink)
  d3.selectAll(".nodeTitle")
    .transition()
    .duration(constants.fadeOut)
    .attr("y", 0)
    .attr("fill", constants.colorText)
  showHyperlink(node, false)
}


function nodeClick() {
  loc = d3.select(this)[0][0].__data__.params.location
  console.log(loc)
  $.get(constants.rascalWebserver + loc)
}


var tree = d3.layout.tree()
  .size([constants.height, constants.width - 160])
  .sort(function(a,b) {
    // order nodes alphabetically based on name
    return (a.name < b.name ? -1 : a.name > b.name ? 1 : 0)
  })
  .separation(function(a, b) {
    return (a.parent == b.parent ? 1 : 1)
  })


var diagonal = d3.svg.diagonal()
  .projection(function(d) {
    return [d.y, d.x]
  })


// enable UI when all information is loaded
function updateUI() {
}


// create a tree for given classname and show
function showGraph(className) {
  loadFacts(makeJSONfile(className))
}


function toggleLegend(show) {
  console.log("legend = " + $("#right_col").css("display"))
  if (show == undefined) {
    show = $("#right_col").css("display") == "none"
  }
  
  var marginRightValue = show ? "200px" : "0px"
  var btnValue = (show ? "Hide" : "Show") + " legend"
  if (show) {
    $("#right_col").show(constants.fadeOut)
  } else {
    $("#right_col").hide(constants.fadeOut)
  }
  $("#page_content").animate({marginRight: marginRightValue}, constants.fadeOut)
  $("#btnLegend").text(btnValue)
}


$(document).ready(function() {
  loadClassnames()
  $(constants.widgetClassnames).combobox()
  $(".custom-combobox-input").focus();
  $("#frmDetails").submit(function(event) {
    event.preventDefault()
  })
	$.each(constants.colorsCC, function(key, value) {
	  $(".CC" + key).css("background-color", constants.colorsCC[key])
	})

	$("#btnLegend").click(function() {
	  toggleLegend()
	})
  //toggleLegend(true)
})
