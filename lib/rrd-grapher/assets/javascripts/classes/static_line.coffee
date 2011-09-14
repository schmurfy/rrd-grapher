
class window.StaticLine
  constructor: (@yvalue, @legend, @yaxis = 1, @formatter = Format.identity) ->
    @enabled = true
    @data = []
    @static = true
    @color = 'black'
  
  set_data: (data) ->
    @data = []
    
    $.each data, (t, v) =>
      @data.push( [Time.server_to_client(t), v] )
    
  get_data: ->
    @data
  
  format: (v) ->
    @formatter(v)
  
  set_legend_color: (element) ->
    tr = $(element).parent()
    tr.toggleClass('transparent', not @enabled)
  
  set_enabled: (new_state) ->
    @enabled = new_state
  
  toggle_enabled: () ->
    this.set_enabled(not @enabled)
  
  get_definition: (from, to) ->
    @data = [
        [Time.server_to_client(from), @yvalue],
        [Time.server_to_client(to), @yvalue]
      ]
    
    {
      data: @data,
      label: @legend,
      yaxis: @yaxis,
      color: @color
    }


