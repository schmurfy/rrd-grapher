
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
    
    @interval = 15*60
    
    # 60s
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
    
    # getTime return a timestamp in UTC so no
    # conversion is required
    to = (new Date().getTime()) - @offset
    to = to / 1000
    from = to - @interval
    
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
      ymin = $.makeArray(ymin)
      if ymin.length == 1
        limits = $.map formatters, -> [[0, ymin[0]]]
      else if ymin.length == 2
        limits = $.map ymin, (val)-> [[0, val]]
        
      
        
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



class window.NTPGraph extends GraphDefinition
  constructor: (container, host, @remote_host, ymin = null) ->
    super(host, container, "NTP", [ Format.delay, Format.identity ], ymin)
    
    # @remote_host2 = @remote_host.replace(/\./g, '-')
    @graph.addSerie("#{@host}/ntpd/time_offset-#{@remote_host}", "seconds", "Offset remote")
    @graph.addSerie("#{@host}/ntpd/time_offset-loop", "seconds", "Offset local")
    
    @graph.addSerie("#{@host}/ntpd/delay-#{@remote_host}", "seconds", "Delay remote")
    
    @graph.addSerie("#{@host}/ntpd/time_dispersion-#{@remote_host}", "seconds", "Dispertion remote")
    @graph.addSerie("#{@host}/ntpd/time_dispersion-LOCAL", "seconds", "Dispertion local")


class window.CPUGraph extends GraphDefinition
  constructor: (container, host, @cpu_index, ymin = null) ->
    super(host, container, "CPU #{@cpu_index}", [ Format.percent, Format.prcent ], ymin)
    @graph.addSerie("#{@host}/cpu-#{@cpu_index}/cpu-user",      'value', 'User')
    @graph.addSerie("#{@host}/cpu-#{@cpu_index}/cpu-system",    'value', 'System')
    @graph.addSerie("#{@host}/cpu-#{@cpu_index}/cpu-interrupt", 'value', 'Interrupt')


class window.DFGraph extends GraphDefinition
  constructor: (container, host, @location, ymin = null) ->
    super(host, container, "Disk use (#{@location})", [ Format.size, Format.size ], ymin)
    @graph.addSerie("#{@host}/df/df-#{@location}",  'used', 'Used')
    @graph.addSerie("#{@host}/df/df-#{@location}",  'free', 'Free')

class window.PingGraph extends GraphDefinition
  constructor: (container, host, @label, @destination, ymin = null) ->
    super(host, container, "Ping #{@label}", [ Format.delay, Format.identity ], ymin)
    
    @graph.addSerie("#{@host}/ping/ping-#{@destination}", 'ping', 'Latency')
    @graph.addSerie("#{@host}/ping/ping_stddev-#{@destination}", 'value', 'stddev')
    @graph.addSerie("#{@host}/ping/ping_droprate-#{@destination}", 'value', 'Loss', 2)
    

class window.NetworkGraph extends GraphDefinition
  constructor: (container, host, @interface, ymin = null) ->
    super(host, container, "Network Traffic (#{interface})", [ Format.size, Format.size ], ymin)

    @graph.addSerie("#{@host}/interface/if_octets-#{@interface}", "rx", "(#{@interface}) Bytes Received")
    @graph.addSerie("#{@host}/interface/if_octets-#{@interface}", "tx", "(#{@interface}) Bytes Sent")


class window.MemoryGraph extends GraphDefinition
  constructor: (container, host, os, ymin = null) ->
    super(host, container, "Memory", [ Format.size, Format.size ], ymin)
    
    if os == "freebsd"
      @graph.addSerie("#{@host}/memory/memory-active",    "value", "Active")
      @graph.addSerie("#{@host}/memory/memory-cache",     "value", "Cached")
      @graph.addSerie("#{@host}/memory/memory-free",      "value", "Free")
      @graph.addSerie("#{@host}/memory/memory-inactive",  "value", "Inactive")
      @graph.addSerie("#{@host}/memory/memory-wired",     "value", "Wired")
    else if os == "linux"
      @graph.addSerie("#{@host}/memory/memory-buffered",  "value", "Buffered")
      @graph.addSerie("#{@host}/memory/memory-cached",    "value", "Caached")
      @graph.addSerie("#{@host}/memory/memory-free",      "value", "Free")
      @graph.addSerie("#{@host}/memory/memory-used",      "value", "Used")


class window.LoadGraph extends GraphDefinition
  constructor: (container, host, ymin = null) ->
    super(host, container, "CPU Load", [ Format.identity, Format.identity ], ymin)

    @graph.addSerie("#{@host}/load/load",    "shortterm", "Load (1min)")
    @graph.addSerie("#{@host}/load/load",    "midterm", "Load (5min)")
    @graph.addSerie("#{@host}/load/load",    "longterm", "Load (15min)")


class window.MonitoringDriftGraph extends GraphDefinition
  constructor: (container, host, ymin = null) ->
    super(host, container, "Clock drift", [ Format.delay, Format.delay ], ymin)
    
    @graph.addSerie("#{@host}/monitoring/gauge-clock_drift", "value", "Drift")
    
