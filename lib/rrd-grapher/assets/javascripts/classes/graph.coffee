
class window.Graph
  colors = ["#edc240", "#afd8f8", "#cb4b4b", "#4da74d", "#9440ed"]
  next_color = 0
  
  constructor: (title, parent_container, formatters, limits) ->
    @formatters = formatters || [Format.identity, Format.identity]
    @limits = limits || [[null, null], [null, null]]
  
    @maxrows = 400;
  
    @legend_containers = [];
  
    # create graph container
    @master_container = $("<div>").addClass("graph_container").appendTo(parent_container)
    @graph_title = $("<div>").addClass("graph_title").appendTo(@master_container)
    @legend_containers[0] = $("<div>").addClass('legend').appendTo(@master_container)
    $("<h3>").text("Legend").appendTo(@legend_containers[0])
    $("<div>").text("Legend").appendTo(@legend_containers[0])
    @container = $("<div>").addClass("graph").appendTo(@master_container)
    # @legend_containers[1] = $("<div>").addClass('legend').appendTo(this.master_container)
    
    @graph_title.text(title)
    
    @series = []
    @lines = []
    @tooltip_point = null
  
    # compute end date (now - 20s)
    @to = Math.floor((new Date().getTime() / 1000) - 20);
    @from = @to - 30;
  
    @plot = null;
    @flot_options =
      legend: { show : false }
      selection: { mode: 'x' }
      grid: { hoverable: true }
      xaxis: { mode: "time", show: true }
      yaxes: [
          {
            min: @limits[0][0],
            max: @limits[0][1],
            tickFormatter: @formatters[0],
            labelWidth: 100
          },
          {
            min: @limits[1][0],
            max: @limits[1][1],
            position: "right",
            labelWidth: 100,
            reserveSpace: true,
            tickFormatter: @formatters[1]
          }
        ]
  
  addSerie: (rrd_path, ds_name, legend, yaxis, formatter) ->
    yaxis = yaxis || 1
    formatter = formatter || @formatters[yaxis - 1]
    
    s = new Serie(rrd_path, ds_name, legend, yaxis, formatter)
    s.color = colors[next_color++]
    @series.push(s)
  
  addLine: (yvalue, color) ->
    l = new StaticLine(yvalue, color)
    @lines.push(l)
  
  create: () ->
    @update_graph(true)
    this
  
  _build_query: (s) ->
    query = "/rrd/#{s.rrd_path}/values/#{@from}/#{@to}?maxrows=#{@maxrows}&ds_name=#{s.ds_name}"
    if s.rra
      query += "&rra=#{s.rra}"
    
    query
  
  update_graph: (first) ->
    first = first || false
    urls = []
    
    urls = $(@series).select( (s) ->  s.enabled ).map (i, s) =>
      [[@_build_query(s), s]]
    
    @multiple_get urls, (data_array) =>
      @_update_graph_common(first, data_array)
    
  
  update_graph_from_cache: () ->
    data_array = []
    
    $.each @series, (i, s) ->
      if s.enabled
        data_array.push( s.get_definition() )
    
    @_update_graph_common(false, data_array)
  
  set_interval: (from, to) ->
    @from = from
    @to = to
  
  _update_graph_common: (first, data_array) ->
    
    # add static data
    $.each @lines, (i, line) ->
      data_array.push( line.get_definition(@from, @to) )
    
    if first
      @plot = $.plot(@container, data_array, @flot_options)
      $(@container).bind("plothover", (event, pos, item) => @show_tooltip(event, pos, item))

      $(@container).bind "plotselected", (event, ranges) =>
        @set_interval(
            Time.client_to_server(ranges.xaxis.from),
            Time.client_to_server(ranges.xaxis.to)
          )
        
        @update_graph()
        @plot.clearSelection()

        
    else
      @plot.setData( data_array )
      @plot.setupGrid()
      @plot.draw()
    
    options = @plot.getOptions()
    
    for i in [0...@series.length]
      @series[i].color = options.colors[i]
    
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
      if @tooltip_point != id
        @tooltip_point = id
        # var s = @series[item.seriesIndex];
        s = $(@series).filter((i, s) -> s.legend == item.series.label ).first()
        
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
      @tooltip_point = null

  create_legend: (index) ->
    # placeholder.find(".legend").remove();
    # series_data = @plot.getData();
    series = @series

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
    @legend_containers[index].find("div").html(table)
    
    # $(@legend_containers[index]).find(".legendColorBox").click () ->
    @legend_containers[index].find(".legendColorBox").click (event) =>
      target = event.currentTarget
      id = $(target).attr("data-serie")
      s = @series[id]
      
      s.toggle_enabled()
      s.set_legend_color(target)
      @update_graph_from_cache()
    
    # @legend_containers[index].wijexpander({expandDirection: "right"})
