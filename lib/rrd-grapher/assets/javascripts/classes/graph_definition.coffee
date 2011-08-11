
class window.GraphController extends Backbone.View
  initialize: ->
    @pages = @options.pages
    

# a page group multiple graph definitions
class window.GraphPage
  constructor: (@container, @panel_container, @host) ->
    @graphs = []
    @autorefresh_timer = null
    
    @autorefresh_checkbox = $("#autorefresh", @panel_container)
    @linked_zoom_checkbox = $("#linkedzoom", @panel_container)
    @date_select          = $("#dateselect", @panel_container)
    
    # 10s
    @offset = 60 * 1000
  
  addGraph: (class_name, args...) ->
    g = new window[class_name](@container, @host, args...)
    g.init()
    g.bind "dblclick", =>
      @set_simple_interval( @interval )
      # disable autorefresh
      @set_autorefresh(null)
      
    g.bind "plotselection", (from, to) =>
      @set_autorefresh(null)
      if @linked_zoom_checkbox.attr("checked")
        @set_interval(from, to)
      
    @graphs.push( g )
  
  set_simple_interval: (interval) ->
    @interval = interval
    
    # clear the date select
    @date_select.val("")
    
    # getTime return a timestamp in UTC so ne
    # conversion is required
    to = (new Date().getTime()) - @offset
    to = to / 1000
    from = to - interval
    
    @set_interval(from, to)
  
  set_interval: (from, to) ->
    $.each @graphs, (i, g) ->
      g.set_interval(from, to)
      g.update_graph()
  
  # set time to null to disable
  set_autorefresh: (time) ->
    # start by killing the timer if any
    if @autorefresh_timer
      window.clearInterval( @autorefresh_timer )
      @autorefresh_timer = null
    
    # and create a new one if asked
    if time
      @autorefresh_checkbox.attr("checked", true)
      @autorefresh_timer = window.setInterval ( => @set_simple_interval(@interval) ), time
    else
      @autorefresh_checkbox.attr("checked", false)
  
  refresh: ->
      @set_simple_interval(@interval)

  
# define a graph with its series
class window.GraphDefinition
  constructor: (@host, @container, @title, formatters, ymin) ->
    _.extend(this, Backbone.Events);
    
    if ymin
      # create an array with the same size as the formatters
      limits = $.map formatters, -> [[0, ymin]]
      # limits = [ [0, ymin], [0, ymin] ]
    else
      limits = null
    
    @graph = new Graph
      "title"             : @title
      "parent_container"  : @container
      "formatters"        : formatters
      "limits"            : limits
    
    @graph.bind "dblclick", => @trigger("dblclick")
    @graph.bind "plotselection", (from, to) => @trigger("plotselection", from, to)
    
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
    @graph.addSerie("#{@host}/memory/memory-cache",     "value", "Cached")
    @graph.addSerie("#{@host}/memory/memory-free",      "value", "Free")
    @graph.addSerie("#{@host}/memory/memory-inactive",  "value", "Inactive")
    @graph.addSerie("#{@host}/memory/memory-wired",     "value", "Wired")


class window.LoadGraph extends GraphDefinition
  constructor: (container, host, ymin = null) ->
    super(host, container, "CPU Load", [ Format.size, Format.size ], ymin)

    @graph.addSerie("#{@host}/load/load",    "shortterm", "Load (1min)")
    @graph.addSerie("#{@host}/load/load",    "midterm", "Load (5min)")
    @graph.addSerie("#{@host}/load/load",    "longterm", "Load (15min)")

