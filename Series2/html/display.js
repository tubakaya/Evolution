
//var factsFile = "/json/SmallSql_formatted.json"
//var factsFile = "/json/TestJ.json"
var factsFile = "/json/TestJTree.json"

var width = 960
var height = 1000
var boxHeight = 60
var boxWidth = 130
var fontSize = 10
var lineSpace = 2

function loadFacts(filename) {
  console.log('loading JSON file: ' + filename)
  d3.json(filename, function(error, facts) {
    console.log('JSON file loaded')
    console.log(facts)
    createTree(facts)
  })
}

function createTree(facts) {
  var nodes = tree.nodes(facts)
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
      .attr("x", -boxWidth/2)
      .attr("y", -boxHeight/2)
      .attr("width", boxWidth)
      .attr("height", boxHeight)
  newNodes.append("text")
    .attr("id", "nodetitle")
    .attr("class", "nodeTitle")
    .attr("y", -boxHeight/2 + fontSize + 2*lineSpace)
    .attr("text-anchor", "middle")
    .text(function(d) {
      return d.name
    })
  newNodes.on("mouseenter", nodeEnter)
  newNodes.on("mouseleave", nodeLeave)
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
//    .style("stroke-width", 20)
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
    .style("stroke-width", strokeWidth)
}

var tree = d3.layout.tree()
  .size([height, width - 160])
  .sort(function(a,b) {
    // order nodes alphabetically based on name
    return (a.name < b.name ? -1 : a.name > b.name ? 1 : 0)
  })

var diagonal = d3.svg.diagonal()
  .projection(function(d) {
    return [d.y, d.x]
  })

var svg = d3.select("body").append("svg")
  .attr("width", width)
  .attr("height", height)
  .append("g")
  .attr("transform", "translate(80,0)")

loadFacts(factsFile);
