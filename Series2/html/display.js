var constants = {
  //factsFile: "/json/SmallSql_formatted.json",
  //factsFile: "/json/TestJ.json",
  factsFile: "/json/test.json",
  rascalWebserver: "http://localhost:8080/showLocation?loc=",
  rascalWebserverInfo: "http://localhost:8080/getInfo?loc=",
  width: 960,
  height: 1000,
  boxHeight: 50,
  boxWidth: 120,
  maxStrokeWidth: 30,
  maxBoxGrowth: 100,
  // I've choosen an analogous color scheme ranging from 'green' (hue 122)
  // for low CC to 'red' (hue 10) for high CC. This gives five colors with
  // hue values: 122, 70, 48, 32, 10.
  // To 'smoothen' the display values (makes them visually less 'hard')
  // decreased the saturation to 77 and brightness to 90.
  // See: http://goo.gl/aANQ1T
  colorsCC: ["#35E53B", "#C7E535", "#E5C235", "#E59335", "#E55335"],
  colorHighlight: "RoyalBlue",
  fadeIn: 1000,
  fadeOut: 400
}


function loadFacts(filename) {
  console.log("reading JSON file")
  d3.json(filename, function(error, data) {
    console.log("JSON file readed")
    console.log(data)
    createGraph(data)
    updateUI()
  })
}


// create a D3 tree
function createGraph(treeData) {
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
      .style("fill", getFillColor)
  newNodes.append("text")
    .attr("id", "nodetitle")
    .attr("class", "nodeTitle")
    .attr("y", 0)
    .attr("text-anchor", "middle")
    .text(getNodeText)
  newNodes.on("mouseenter", nodeEnter)
  newNodes.on("mouseleave", nodeLeave)
  newNodes.on("click", nodeClick)
  
  // update links after all nodes are added
  newLinks.style("stroke-width", getStrokeWidth)
}


function getNodeID(d) {
  console.log(d.name)
  console.log(d)
  if (d.depth == 0) {
    return "rootnode"
  }
  return "";
}

function getNodeText(d) {
  return d.name
}

// get link stroke-width based on ClassInfo dependency count
function getStrokeWidth(d) {
  var maxDepend = getMaxDependencyCount()
  maxDepend = maxDepend == 0 ? 1 : maxDepend
  var strokeWidth = (d.target.params.dependencyCount / maxDepend) * constants.maxStrokeWidth
  // ensure that stroke-width is at least 2
  strokeWidth = strokeWidth < 2 ? 2 : strokeWidth;
  return strokeWidth
}

function getMaxDependencyCount() {
  var rootNode = d3.select("#rootnode")[0][0].__data__
  var result = d3.max(rootNode.children.map(function(d) {
    return d.params.dependencyCount
  }))
  return result
}

// get node color based on ClassInfo Cyclomatic Complexity
function getFillColor(d) {
  return constants.colorsCC[d.params.CC-1]
}

// get node growth factor based on ClassInfo LOC
function getBoxGrowth(d) {
  var maxLOC = getMaxLOC()
  maxLOC = maxLOC == 0 ? 1 : maxLOC
  return (d.params.LOC / getMaxLOC()) * constants.maxBoxGrowth
}

function getMaxLOC() {
  var rootNode = d3.select("#rootnode")[0][0].__data__
  var result = d3.max(rootNode.children.map(function(d) {
    return d.params.LOC
  }))
  return result
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


function nodeEnter(p) {
  //TODO: transitions onEnter do not work??
  d3.select(this).selectAll(".nodebox")
    .transition()
    .duration(constants.fadeIn)
    .style("fill", constants.colorHighlight)
  svg.selectAll(".link")
    .transition()
    .duration(constants.fadeIn)
    .style("stroke", constants.colorHighlight)
    
  //TODO: show complete packagename?

  //TODO: highlight only path from this node to parent
  console.log(p)
  console.log(svg.selectAll(".link"))
  
}


function nodeLeave() {
  d3.select(this).selectAll(".nodebox")
    .transition()
    .duration(constants.fadeOut)
    .style("fill", getFillColor)
  svg.selectAll(".link")
    .transition()
    .duration(constants.fadeOut)
    .style("stroke", null)
}


function nodeClick() {
  console.log(d3.select(this))
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
    return (a.parent == b.parent ? 1 : 2);
  })


var diagonal = d3.svg.diagonal()
  .projection(function(d) {
    return [d.y, d.x]
  })


var svg = d3.select("body").append("svg")
  .attr("width", constants.width)
  .attr("height", constants.height)
  .append("g")
  .attr("transform", "translate(80,0)")


// enable UI when all information is loaded
function updateUI() {
  $("#btnFindClass").removeAttr('disabled')
}


// create a tree for given classname and show
function showGraph(className) {
  //TODO: implement, add classname which should be root
  loadFacts(constants.factsFile)
}


$(document).ready(function() {
  $("#frmDetails").submit(function(event) {
    showGraph($("#txtClassname").val())
    event.preventDefault()
  })
  updateUI()
})
