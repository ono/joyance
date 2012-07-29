var App = App || {};

App.config = {
  canvasWidth: 500,
  canvasHeight: 500,

  sentiments_totals_url: "/streams/olympics/total.json",
  graph_container_sel: "#love-hate-bar-graph"
};

function renderLoveHateGraph(data) {

  var w = App.config.canvasWidth,
      h = App.config.canvasHeight,
      r = Math.min(w, h) / 2,
      color = d3.scale.category20(),
      donut = d3.layout.pie()
        .sort(null)
        .value(function(d) {
          return d.total; // Use the 'total' from the hash
        }),
      arc = d3.svg.arc().innerRadius(r - 100).outerRadius(r - 20);

  var svg = d3.select("body").append("svg:svg")
      .attr("width", w)
      .attr("height", h)
    .append("svg:g")
      .attr("transform", "translate(" + w / 2 + "," + h / 2 + ")");

  var arcs = svg.selectAll("path")
      .data(donut(data))
    .enter().append("svg:path")
      .attr("fill", function(d, i) { return color(i); })
      .attr("d", arc)
      .each(function(d) { this._current = d; });

}

$(function (data) {
  // Get json data
  d3.json(App.config.sentiments_totals_url, function(data) {
    App.data = data;
    renderLoveHateGraph(data);
  });
});