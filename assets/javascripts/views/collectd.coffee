
class CollectdPage extends GraphPage
  constructor: (container, host) ->
    super(container, host)
    
    @addGraph("NetworkGraph", "en0", 1 * Size.megabyte )
    @addGraph("NetworkGraph", "en1", 1 * Size.megabyte )
    @addGraph("MemoryGraph")
    @addGraph("LoadGraph", 2.0)



$ ->
  graphs = []
  
  $('#toggle_config').click ->
    $("#config_panel").fadeToggle()
  
  container = $("#graphs")
  
  page = new CollectdPage(container, "pomme.local")
  page.refresh(1*60*60, 1000)
  
  # periodic_update = (g) ->
  #   g.to = Math.floor((new Date().getTime() / 1000) - 10)
  #   g.from = g.to - 30
  #   g.update_graph()
  #   window.setTimeout( (-> periodic_update(g)), 2000)
  # 
  # create_graph_net= (interface, host) ->
  #   g = new Graph("Network Traffic (#{interface})", container, [ Format.size, Format.size ],
  #       [ [0, 1*1024*1024], [0, 1*1024*1024] ]
  #       )
  # 
  #   g.addSerie("#{host}/interface/if_octets-#{interface}", "rx", "Bytes Received")
  #   g.addSerie("#{host}/interface/if_octets-#{interface}", "tx", "Bytes Sent", 2)
  #   g.create()
  # 
  #   graphs.push( g )
  #   # periodic_update(g)
  # 
  # 
  # create_graph_memory= (host) ->
  #   g = new Graph("Memory", container, [ Format.size, Format.size ],
  #       [ [0, 1*1024*1024], [0, 1*1024*1024] ]
  #       )
  # 
  #   g.addSerie("#{host}/memory/memory-active",    "value", "Active")
  #   g.addSerie("#{host}/memory/memory-free",      "value", "Free")
  #   g.addSerie("#{host}/memory/memory-inactive",  "value", "Inactive")
  #   g.addSerie("#{host}/memory/memory-wired",     "value", "Wired")
  #   g.create()
  # 
  #   graphs.push( g )
  #   # periodic_update(g)
  # 
  # 
  # create_graph_load= (host) ->
  #   g = new Graph("CPU Load", container, [ Format.size, Format.size ],
  #       [ [0, 1*1024*1024], [0, 1*1024*1024] ]
  #       )
  # 
  #   g.addSerie("#{host}/load/load",    "shortterm", "Load (1min)")
  #   g.addSerie("#{host}/load/load",    "midterm", "Load (5min)")
  #   g.addSerie("#{host}/load/load",    "longterm", "Load (15min)")
  #   g.create()
  # 
  #   graphs.push( g )
  #   # periodic_update(g)
  # 
  # create_graph_net("en1", "pomme.local")
  # create_graph_memory("pomme.local")
  # create_graph_load("pomme.local")


