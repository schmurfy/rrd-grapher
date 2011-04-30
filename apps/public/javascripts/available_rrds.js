

$(function(){
  list_rrd(function(data){
    console.log(data);
    $("#template").tmpl(data).appendTo("#target");
    // $("#time").showTime( { div_hours: "h ", div_minutes: "m ", div_seconds: "s " } );
    $("#target .timestamp").humaneDates();
  });
});
