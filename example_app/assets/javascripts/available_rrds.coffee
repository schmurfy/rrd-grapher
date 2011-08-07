
list_rrd = (callback) ->
  jQuery.get "/rrd", (o) ->
    callback(o)

$ ->
  list_rrd (data) ->
    # $("#template").tmpl(data).appendTo("#target")
    tmp = $("#template").tmpl(data)
    tmp.appendTo("#data_list")
    # $("#time").showTime( { div_hours: "h ", div_minutes: "m ", div_seconds: "s " } )
    $(".time").timeago()
    
