

$(function(){
  list_rrd(function(data){
    console.log(data);
    // $("#template").tmpl(data).appendTo("#target");
    var tmp = $("#template").tmpl(data);
    tmp.appendTo("#data_list");
    // $("#time").showTime( { div_hours: "h ", div_minutes: "m ", div_seconds: "s " } );
    // $("#target .timestamp").humaneDates();
  });
});
