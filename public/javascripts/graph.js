
$(function(){
  
  var button = $('#add_graph').button();
  
  // load available rrds
  var graph_list = $("#graphs_list");
  list_rrd(function(data){
    $.each(data, function(i, o){
        graph_list.append('<option value="' + o.short_name + '">' + o.short_name + '</option>');
      });
  });
  
  var container = $("#graph_container");
  var graphs = [];
  var g = new Graph(container, [ Format.size, Format.speed]);
  
  g.addSerie("4series", "value1", "Value 1", 1, Format.size);
  g.addSerie("4series", "value2", "Value 2", 2);
  g.addSerie("4series", "value3", "Value 3", 2);
  g.addSerie("4series", "value4", "Value 4", 2);
  g.addLine(1024, 'green');
  g.addLine(4096, 'red');
  g.create();
  
  graphs.push( g );
  
  // load first graph
  button.click(function(){
    var g = new Graph(container);
    g.addSerie(graph_list.val(), 'value', 'Important value !');
    g.create();
    
    graphs.push( g );
  });
  
  
  
  window.setInterval(function(){
      g.to = Math.floor((new Date().getTime() / 1000) - 2);
      g.from = g.to - 30;
      g.update_graph();
    }, 1000);
  
});

