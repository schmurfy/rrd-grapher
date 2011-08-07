(function() {
  var list_rrd;
  list_rrd = function(callback) {
    return jQuery.get("/rrd", function(o) {
      return callback(o);
    });
  };
  $(function() {
    return list_rrd(function(data) {
      var tmp;
      tmp = $("#template").tmpl(data);
      tmp.appendTo("#data_list");
      return $(".time").timeago();
    });
  });
}).call(this);
