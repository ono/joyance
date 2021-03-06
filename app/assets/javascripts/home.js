var App = App || {};

App.config = {
  canvasWidth: 500,
  canvasHeight: 500,

  pusher_app_id: "a8d6b011ca9900b8ece8",
  stream: "olympics",
  sentiments_totals_url: "/streams/olympics/total.json",
  graph_container_sel: "#love-hate-bar-graph",

  forceWidth: 800,
  forceHeight: 600,
  forceMaxSize: 200,
  forceGravity: 0.05,
  force_container_sel: "#force-graph",

  newTweetSel: "#new-tweet",
};

function renderLoveHateGraph(data) {
    var w = App.config.canvasWidth,
    h = App.config.canvasHeight,
    r = Math.min(w, h) / 2,
    color = d3.scale.category20c();     //builtin range of colors

    var vis = d3.select("body")
        .append("svg:svg")              //create the SVG element inside the <body>
            .attr("id", "pie_chart")
        .data([data])                   //associate our data with the document
            .attr("width", w)           //set the width and height of our visualization (these will be attributes of the <svg> tag
            .attr("height", h)
        .append("svg:g")                //make a group to hold our pie chart
            .attr("transform", "translate(" + r + "," + r + ")")    //move the center of the pie chart from 0, 0 to radius, radius

    var arc = d3.svg.arc()              //this will create <path> elements for us using arc data
        .outerRadius(r);

    var pie = d3.layout.pie()           //this will create arc data for us given a list of values
        .value(function(d) { return d.total; });    //we must tell it out to access the value of each element in our data array

    var arcs = vis.selectAll("g.slice")     //this selects all <g> elements with class slice (there aren't any yet)
        .data(pie)                          //associate the generated pie data (an array of arcs, each having startAngle, endAngle and value properties) 
        .enter()                            //this will create <g> elements for every "extra" data element that should be associated with a selection. The result is creating a <g> for every object in the data array
            .append("svg:g")                //create a group to hold each slice (we will have a <path> and a <text> element associated with each slice)
                .attr("class", "slice");    //allow us to style things in the slices (like text)

        arcs.append("svg:path")
                .attr("fill", function(d, i) { return color(i); } ) //set the color for each slice to be chosen from the color function defined above
                .attr("d", arc);                                    //this creates the actual SVG path using the associated data (pie) with the arc drawing function

        arcs.append("svg:text")                                     //add a label to each slice
                .attr("transform", function(d) {                    //set the label's origin to the center of the arc
                //we have to make sure to set these before calling arc.centroid
                d.innerRadius = 0;
                d.outerRadius = r;
                return "translate(" + arc.centroid(d) + ")";        //this gives us a pair of coordinates like [50, 50]
            })
            .attr("text-anchor", "middle")                          //center the text on it's origin
            .text(function(d, i) {
              var overallTotal = _.reduce(data, function(memo, d) { return memo + d.total; }, 0)
              var percentage = Math.round(data[i].total / overallTotal * 100);
              return data[i].sentiment + " (" + percentage + "%)";
            });
  }

function initForceGraph(data) {
  var w = App.config.forceWidth,
      h = App.config.forceHeight;

  App.circleScale = d3.scale.linear()
      .range([0, App.config.forceMaxSize]);
  App.svg = d3.select(App.config.force_container_sel).append("svg:svg")
      .attr("width", w)
      .attr("height", h);

  updateForceGraph(data);
}

function updateForceGraph(data) {
  var w = App.config.forceWidth,
      h = App.config.forceHeight,
      g = App.config.forceGravity,
      overallTotal = _.reduce(data, function(memo, d) { return memo + d.total; }, 0),
      nodes = data.map(function(d) {
        return {
          sentiment: d.sentiment,
          total: d.total,
          radius: App.circleScale(d.total / overallTotal)
        };
      });

  App.nodes = nodes;

  var force = d3.layout.force()
      .gravity(g)
      .charge(function(d, i) { return i ? 0 : -2000; })
      .nodes(nodes)
      .size([w, h]);

  force.start();

  App.svg.selectAll("circle")
      .data(nodes.slice(1)) // Ignore mouse node
    .enter().append("svg:circle")
      .attr("class", function(d) {
        return "sentiment-" + d.sentiment;
      })
      .attr("data-sentiment", function(d) { return d.sentiment; })
      .attr("data-total", function(d) { return d.total; })
      .attr("r", function(d) {
        return d.radius - 2;
      });

  force.on("tick", function(e) {
    var q = d3.geom.quadtree(nodes),
        i = 0,
        n = nodes.length;

    while (++i < n) {
      q.visit(collide(nodes[i]));
    }

    App.svg.selectAll("circle")
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
  });

  // Make the neutral node the mouse node
  // var mouseNode = _.find(App.nodes, function(n) { return n.sentiment == "neutral";});
  var mouseNode = nodes[0];
  mouseNode.fixed = true;
  App.svg.on("mousemove", function() {
    var p1 = d3.svg.mouse(this);
    mouseNode.px = p1[0];
    mouseNode.py = p1[1];
    force.resume();
  });

  function collide(node) {
    var r = node.radius + 16,
        nx1 = node.x - r,
        nx2 = node.x + r,
        ny1 = node.y - r,
        ny2 = node.y + r;
    return function(quad, x1, y1, x2, y2) {
      if (quad.point && (quad.point !== node)) {
        var x = node.x - quad.point.x,
            y = node.y - quad.point.y,
            l = Math.sqrt(x * x + y * y),
            r = node.radius + quad.point.radius;
        if (l < r) {
          l = (l - r) / l * .5;
          node.x -= x *= l;
          node.y -= y *= l;
          quad.point.x += x;
          quad.point.y += y;
        }
      }
      return x1 > nx2
          || x2 < nx1
          || y1 > ny2
          || y2 < ny1;
    };
  }
}

$(function () {
  // Initial load from db
  // d3.json(App.config.sentiments_totals_url, function(data) {
  //   App.data = data;
  //   App.prevData = data;
  // });

  var pusher = new Pusher(App.config.pusher_app_id); // Replace with your app key
  var channel = pusher.subscribe(App.config.stream);

  App.prevData = null;
  channel.bind('recent', function(data) {
    // Filter out neutral
    data = _.reject(data, function(d) { return d.sentiment == "neutral" });
    data.unshift({total: 0}); // Add dummy node for mouse movement
    console.log(data);
    if (!App.prevData) {
      initForceGraph(data);
    }
    console.log(_.pluck(App.prevData, "sentiment"));
    console.log(_.pluck(App.prevData, "total"));
    updateForceGraph(data);
    App.prevData = data;
    console.log(_.pluck(data, "total"));
  });

  var newTweetSel = App.config.newTweetSel;
  channel.bind('tweet', function(data) {
    console.log(data);
    $(newTweetSel).html(data.raw.interaction.content);
    $(newTweetSel).attr("class", "sentiment-" + data.sentiment);
    // App.data = data;
    // renderLoveHateGraph(data);
  });

});
