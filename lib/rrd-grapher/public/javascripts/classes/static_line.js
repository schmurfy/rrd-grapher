(function() {
  window.StaticLine = (function() {
    function StaticLine(yvalue, color) {
      this.yvalue = yvalue;
      this.color = color;
    }
    StaticLine.prototype.get_definition = function(from, to) {
      return {
        data: [[Time.server_to_client(from), this.yvalue], [Time.server_to_client(to), this.yvalue]],
        legend: "",
        color: this.color
      };
    };
    return StaticLine;
  })();
}).call(this);
