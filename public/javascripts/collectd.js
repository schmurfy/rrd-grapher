
$(function(){
  var graphs = [];
  var container = $("#graph_container");
  
  // function periodic_update(g){
  //   g.to = Math.floor((new Date().getTime() / 1000) - 10);
  //   g.from = g.to - 30;
  //   g.update_graph();
  //   // window.setTimeout(periodic_update, 2000);
  // }
  
  function create_graph_net_en0(){
    var g = new Graph(container, [ Format.size, Format.size ],
        [ [0, 1*1024*1024], [0, 1*1024*1024] ]
        );

    g.addSerie("pomme.local/interface/if_octets-en0", "rx", "Bytes Received");
    g.addSerie("pomme.local/interface/if_octets-en0", "tx", "Bytes Sent", 2);
    g.create();

    graphs.push( g );
    // periodic_update(g);
  }
  
  function create_graph_memory(){
    var g = new Graph(container, [ Format.size, Format.size ],
        [ [0, 1*1024*1024], [0, 1*1024*1024] ]
        );

    g.addSerie("pomme.local/memory/memory-active",    "value", "Active");
    g.addSerie("pomme.local/memory/memory-free",      "value", "Free");
    g.addSerie("pomme.local/memory/memory-inactive",  "value", "Inactive");
    g.addSerie("pomme.local/memory/memory-wired",     "value", "Wired");
    g.create();

    graphs.push( g );
    // periodic_update(g);
  }
  
  function create_graph_load(){
    var g = new Graph(container, [ Format.size, Format.size ],
        [ [0, 1*1024*1024], [0, 1*1024*1024] ]
        );

    g.addSerie("pomme.local/load/load",    "shortterm", "Load (1min)");
    g.addSerie("pomme.local/load/load",    "midterm", "Load (5min)");
    g.addSerie("pomme.local/load/load",    "longterm", "Load (15min)");
    g.create();

    graphs.push( g );
    // periodic_update(g);
  }
  
  create_graph_net_en0();
  create_graph_memory();
  create_graph_load();
  
});

