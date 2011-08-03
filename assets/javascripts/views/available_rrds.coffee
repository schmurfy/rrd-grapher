
$ ->
  list_rrd (data) ->
    # $("#template").tmpl(data).appendTo("#target")
    tmp = $("#template").tmpl(data)
    tmp.appendTo("#data_list")
    # $("#time").showTime( { div_hours: "h ", div_minutes: "m ", div_seconds: "s " } )
    # $("#target .timestamp").humaneDates()
    
