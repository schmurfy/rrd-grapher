

function list_rrd(){
  jQuery.get("/rrd", function(data, status){
    console.log(data);
    $("#template").tmpl(data).appendTo("#target");
    // $("#time").showTime( { div_hours: "h ", div_minutes: "m ", div_seconds: "s " } );
    $("#target .timestamp").humaneDates();
  });
}


$(function(){
  list_rrd();
  $('#button').button();
});
