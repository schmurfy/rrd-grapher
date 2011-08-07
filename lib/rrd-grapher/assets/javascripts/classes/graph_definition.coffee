
# a page group multiple graph definitions
class window.GraphPage
  constructor: (@container, @host) ->
    @graphs = []
  
  addGraph: (class_name, args...) ->
    g = new window[class_name](@container, @host, args...)
    g.init()
    @graphs.push( g )
  
  refresh: (interval, time = null) ->
    to = Math.floor((new Date().getTime() / 1000) - 10)
    from = to - interval

    $.each @graphs, (i, g) -> g.set_interval(from, to)
    
    if time
      @refresh(interval)
      me = this
      int = interval
      window.setTimeout( (-> me.refresh(int, time)), time)
    else
      $.each @graphs, (i, g) -> g.update_graph()

  
# define a graph with its series
class window.GraphDefinition
  constructor: (@host, @container, @title, formatters, ymin) ->
    if ymin
      # create an array with the same size as the formatters
      limits = $.map formatters, -> [[0, ymin]]
      # limits = [ [0, ymin], [0, ymin] ]
    else
      limits = null
    
    @graph = new Graph(@title, @container, formatters, limits)
    
  init: ->
    @graph.create()
  
  set_interval: (from, to) ->
    @graph.set_interval(from, to)
  
  update_graph: ->
    @graph.update_graph()


class window.NetworkGraph extends GraphDefinition
  constructor: (container, host, @interface, ymin = null) ->
    super(host, container, "Network Traffic (#{interface})", [ Format.size, Format.size ], ymin)

    @graph.addSerie("#{@host}/interface/if_octets-#{@interface}", "rx", "(#{@interface}) Bytes Received")
    @graph.addSerie("#{@host}/interface/if_octets-#{@interface}", "tx", "(#{@interface}) Bytes Sent")
    @graph.create()


class window.MemoryGraph extends GraphDefinition
  constructor: (container, host, ymin = null) ->
    super(host, container, "Memory", [ Format.size, Format.size ], ymin)

    @graph.addSerie("#{@host}/memory/memory-active",    "value", "Active")
    @graph.addSerie("#{@host}/memory/memory-free",      "value", "Free")
    @graph.addSerie("#{@host}/memory/memory-inactive",  "value", "Inactive")
    @graph.addSerie("#{@host}/memory/memory-wired",     "value", "Wired")


class window.LoadGraph extends GraphDefinition
  constructor: (container, host, ymin = null) ->
    super(host, container, "CPU Load", [ Format.size, Format.size ], ymin)

    @graph.addSerie("#{@host}/load/load",    "shortterm", "Load (1min)")
    @graph.addSerie("#{@host}/load/load",    "midterm", "Load (5min)")
    @graph.addSerie("#{@host}/load/load",    "longterm", "Load (15min)")

