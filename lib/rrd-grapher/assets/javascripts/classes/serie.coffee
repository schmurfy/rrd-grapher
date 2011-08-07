
class window.Serie
  constructor: (@rrd_path, @ds_name, @legend, @yaxis = 1, @formatter = Format.identity, @rra = null) ->
    @enabled = true
    @color = 'black'
    @data = []
  
  set_legend_color: (element) ->
    tr = $(element).parent()
    
    if @enabled
      tr.removeClass('transparent')
    else
      tr.addClass('transparent')
  
  set_enabled: (new_state) ->
    @enabled = new_state
  
  toggle_enabled: () ->
    new_state = not @enabled
    @set_enabled(new_state)
  
  get_definition: () ->
    {
      data: @data,
      label: @legend,
      yaxis: @yaxis,
      color: @color
    }
  
  get_data: () ->
    @data
  
  set_data: (data) ->
    @data = []
    
    $.each data, (t, v) =>
      @data.push( [Time.server_to_client(t), v] )
  
  format: (v) ->
    @formatter(v)
