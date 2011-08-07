
class window.StaticLine
  constructor: (@yvalue, @color) ->
  
  get_definition: (from, to) ->
    {
      data: [
          [Time.server_to_client(from), @yvalue],
          [Time.server_to_client(to), @yvalue]
        ],
      legend: "",
      color: @color
    }

