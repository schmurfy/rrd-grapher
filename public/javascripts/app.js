
var tz_offset = -( new Date() ).getTimezoneOffset() ;

function list_rrd(callback){
  jQuery.get("/rrd", function(o){
    callback(o);
  });
}
