
class window.Graph extends Backbone.Model
  colors = ["#edc240", "#afd8f8", "#cb4b4b", "#4da74d", "#9440ed"]
  next_color = 0
  
  defaults:
    "formatters"  : [Format.identity, Format.identity]
    "limits"      : [[null, null], [null, null]]
  
  initialize: ->
    # super
    #   "formatters"  : formatters
    #   "limits"      : limits
    
    @set "maxrows" : 400
    @set "legend_containers" : []
    
    parent_container = @get("parent_container")
    title = @get("title")
    
    @set("limits" : @defaults["limits"]) if @get("limits") == null
    
    # create graph container
    master_container = $("<div>").addClass("graph_container").appendTo(parent_container)
    @set "master_container" : master_container
    
    # @set "graph_title"      : $("<div>").addClass("graph_title").appendTo(master_container)
    # @get("graph_title").text(title)
    
    @get("legend_containers")[0] = $("<div>").addClass('legend').appendTo(master_container)
    $("<h3>").text(title).appendTo(@get("legend_containers")[0])
    $("<div>").appendTo(@get("legend_containers")[0])
    
    @set "container" : $("<div>").addClass("graph").appendTo(master_container)
    # @legend_containers[1] = $("<div>").addClass('legend').appendTo(this.master_container)
    
    @set "series"         : []
    @set "lines"          : []
    @set "tooltip_point"  : null
  
    # compute end date (now - 20s)
    to = Math.floor((new Date().getTime() / 1000) - 20)
    @set "to"   : to 
    @set "from" : to - 30
  
    @set "plot" : null
    @set "flot_options" :
      "legend"    : { show : false }
      "selection" : { mode: 'x' }
      "grid"      : { hoverable: true }
      "xaxis"     : { mode: "time", show: true }
      "yaxes"     : [
          {
            "min"           : @get("limits")[0][0]
            "max"           : @get("limits")[0][1]
            "tickFormatter" : @get("formatters")[0]
            "labelWidth"    : 100
          },
          {
            "min"           : @get("limits")[1][0]
            "max"           : @get("limits")[1][1]
            "position"      : "right"
            "labelWidth"    : 100
            "reserveSpace"  : true
            "tickFormatter" : @get("formatters")[1]
          }
        ]
  
  addSerie: (rrd_path, ds_name, legend, yaxis, formatter) ->
    yaxis = yaxis || 1
    formatter = formatter || @get("formatters")[yaxis - 1]
    
    s = new Serie(rrd_path, ds_name, legend, yaxis, formatter)
    s.color = colors[next_color++]
    @get("series").push(s)
  
  addLine: (yvalue, color) ->
    l = new StaticLine(yvalue, color)
    @get("lines").push(l)
  
  create: () ->
    this.update_graph(true)
    this
  
  _build_query: (s) ->
    query = "/rrd/#{s.rrd_path}/values/#{@get('from')}/#{@get('to')}?maxrows=#{@get('maxrows')}&ds_name=#{s.ds_name}"
    if s.rra
      query += "&rra=#{s.rra}"
    
    query
  
  update_graph: (first) ->
    first = first || false
    urls = []
    
    urls = $(@get("series")).select( (s) ->  s.enabled ).map (i, s) =>
      [[@_build_query(s), s]]
    
    @multiple_get urls, (data_array) =>
      @_update_graph_common(first, data_array)
    
  
  update_graph_from_cache: () ->
    data_array = []
    
    $.each @get("series"), (i, s) ->
      if s.enabled
        data_array.push( s.get_definition() )
    
    @_update_graph_common(false, data_array)
  
  set_interval: (from, to) ->
    @set "from" : from
    @set "to"   : to
  
  _update_graph_common: (first, data_array) ->
    
    # add static data
    $.each @get("lines"), (i, line) ->
      data_array.push( line.get_definition(@get("from"), @get("to")) )
    
    if first
      @set "plot" : $.plot(@get("container"), data_array, @get("flot_options"))
      $(@get("container")).bind("plothover", (event, pos, item) => @show_tooltip(event, pos, item))

      $(@get("container")).bind "plotselected", (event, ranges) =>
        @set_interval(
            Time.client_to_server(ranges.xaxis.from),
            Time.client_to_server(ranges.xaxis.to)
          )
        
        @update_graph()
        @get("plot").clearSelection()

        
    else
      plot = @get("plot")
      plot.setData( data_array )
      plot.setupGrid()
      plot.draw()
    
    options = @get("plot").getOptions()
    
    for i in [0...@get("series").length]
      @get("series")[i].color = options.colors[i]
    
    if first
      @create_legend(0)
      # @create_legend(1)
  
  multiple_get: (urls, when_done_cb) ->
    urls = $.makeArray(urls)
    left = urls.length
    ret = []
    
    $(urls).each (i, el) ->
      url = el[0]
      serie = el[1]
      
      $.getJSON url, (data) ->
        serie.set_data(data)
        ret.push( serie.get_definition() )
        left -= 1
        when_done_cb(ret) if left == 0
  
  min: (s) ->
    ret = s.data[0][1]
    $.each s.data, (i, pair) ->
      if pair[1] < ret
        ret = pair[1]
    
    ret
  
  max: (s) ->
    ret = s.data[0][1]
    $.each s.data, (i, pair) ->
      if pair[1] > ret
        ret = pair[1]
    
    ret
  
  show_tooltip: (event, pos, item) ->
    if item
      id = "" + item.seriesIndex + ":" + item.dataIndex
      if @get("tooltip_point") != id
        @set "tooltip_point" : id
        # var s = @series[item.seriesIndex];
        s = $(@get("series")).filter((i, s) -> s.legend == item.series.label ).first()
        
        if s.length > 0
          s = s[0]
          $("#tooltip").remove()
          y = item.datapoint[1]
          item_date = new Date(item.datapoint[0])
          date_str = item_date.getHours() + ":" + item_date.getMinutes()
        
          content = s.format(y) + '<br/>' + date_str + "<br/>" + s.legend;
        
          $('<div id="tooltip">' + content + '</div>').css( {
              position: 'absolute',
              display: 'none',
              top: item.pageY - 5,
              left: item.pageX + 15,
              border: '1px solid #fdd',
              padding: '2px',
              'background-color': '#fee',
              opacity: 0.80
          }).appendTo("body").fadeIn(200)
          
    else
      $("#tooltip").remove()
      @set "tooltip_point" : null

  create_legend: (index) ->
    # placeholder.find(".legend").remove();
    # series_data = @plot.getData();
    series = @get("series")

    fragments = []
    rowStarted = false

    fragments.push("<tr><th></th><th>label</th><th>Min</th><th>Max</th></tr>")
    
    for i in [0...series.length]
      s = series[i]
      label = s.legend
      
      if !label # || (s.yaxis != (index + 1)) 
        continue

      if i % 1 == 0          
        fragments.push('</tr>') if rowStarted
        fragments.push('<tr>')
        rowStarted = true;

      # label = lf(label, s) if lf
      fragments.push(
          '<td data-serie="' + i + '" class="legendColorBox"><div class="outerBorder"><div style="width:4px;height:0;border:5px solid ' + s.color + ';overflow:hidden"></div></div></td>')
      
      fragments.push('<td class="legendLabel">' + label + '</td>')
      fragments.push("<td>#{s.format( @min(s) )}</td>")
      fragments.push("<td>#{s.format( @max(s) )}</td>")
    
    
    fragments.push('</tr>') if rowStarted

    return if fragments.length == 0

    table = '<table style="font-size:smaller;color:#545454">' + fragments.join("") + '</table>'
    @get("legend_containers")[index].find("div").html(table)
    
    # $(@legend_containers[index]).find(".legendColorBox").click () ->
    @get("legend_containers")[index].find(".legendColorBox").click (event) =>
      target = event.currentTarget
      id = $(target).attr("data-serie")
      s = @get("series")[id]
      
      s.toggle_enabled()
      s.set_legend_color(target)
      @update_graph_from_cache()
    
    # @legend_containers[index].wijexpander({expandDirection: "right"})
