var constants = {
  //factsFile: "/json/SmallSql_formatted.json",
  //factsFile: "/json/TestJ.json",
  factsFile: "/json/test.json",
  rascalWebserver: "http://localhost:8080/showLocation?loc=",
  rascalWebserverInfo: "http://localhost:8080/getInfo?loc=",
  width: 960,
  height: 1000,
  boxHeight: 60,
  boxWidth: 130,
  fontSize: 10,
  lineSpace: 2
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
    .duration(1000)
    .style("stroke-width", strokeWidth)
  
  // update and add nodes
  var existingNodes = svg.selectAll(".node").data(nodes)
  var newNodes = existingNodes.enter().append("g")
    .attr("class", "node")
    .attr("id", function(d) {
      console.log(d.name)
      return d.name
     })
    .attr("transform", function(d) {
      return "translate(" + d.y + "," + d.x + ")"
    })
  newNodes.append("rect")
      .attr('class', 'nodebox')
      .attr("x", -constants.boxWidth/2)
      .attr("y", -constants.boxHeight/2)
      .attr("width", constants.boxWidth)
      .attr("height", constants.boxHeight)
  newNodes.append("text")
    .attr("id", "nodetitle")
    .attr("class", "nodeTitle")
    .attr("y", -constants.boxHeight/2 + constants.fontSize + 2*constants.lineSpace)
    .attr("text-anchor", "middle")
    .text(function(d) {
      return d.name
    })
  newNodes.on("mouseenter", nodeEnter)
  newNodes.on("mouseleave", nodeLeave)
  newNodes.on("click", nodeClick)
}


function strokeWidth(d) {
  return d.target.params.dependencyCount*3
}


function nodeEnter() {
  thisNode = d3.select(this)
  color = thisNode.select(".nodebox").style("stroke")
  thisNode.selectAll(".nodebox")
    .transition()
    .duration(1000)
    .style("fill", color)
  svg.selectAll(".link")
    .transition()
    .duration(1000)
    .style("stroke", color)
}


function nodeLeave() {
  d3.select(this).selectAll(".nodebox")
    .transition()
    .duration(250)
    .style("fill", null)
  svg.selectAll(".link")
    .transition()
    .duration(250)
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
