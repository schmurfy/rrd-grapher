
class window.Serie extends StaticLine
  constructor: (@rrd_path, @ds_name, @legend, @yaxis = 1, @formatter = Format.identity, @rra = null) ->
    super(null, legend, yaxis, formatter)
    @static = false
  
  get_definition: () ->
    {
      data: @data,
      label: @legend,
      yaxis: @yaxis,
      color: @color
    }
