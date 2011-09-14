(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.StaticLine = (function() {
    function StaticLine(yvalue, legend, yaxis, formatter) {
      this.yvalue = yvalue;
      this.legend = legend;
      this.yaxis = yaxis != null ? yaxis : 1;
      this.formatter = formatter != null ? formatter : Format.identity;
      this.enabled = true;
      this.data = [];
      this.static = true;
      this.color = 'black';
    }
    StaticLine.prototype.set_data = function(data) {
      this.data = [];
      return $.each(data, __bind(function(t, v) {
        return this.data.push([Time.server_to_client(t), v]);
      }, this));
    };
    StaticLine.prototype.get_data = function() {
      return this.data;
    };
    StaticLine.prototype.format = function(v) {
      return this.formatter(v);
    };
    StaticLine.prototype.set_legend_color = function(element) {
      var tr;
      tr = $(element).parent();
      return tr.toggleClass('transparent', !this.enabled);
    };
    StaticLine.prototype.set_enabled = function(new_state) {
      return this.enabled = new_state;
    };
    StaticLine.prototype.toggle_enabled = function() {
      return this.set_enabled(!this.enabled);
    };
    StaticLine.prototype.get_definition = function(from, to) {
      this.data = [[Time.server_to_client(from), this.yvalue], [Time.server_to_client(to), this.yvalue]];
      return {
        data: this.data,
        label: this.legend,
        yaxis: this.yaxis,
        color: this.color
      };
    };
    return StaticLine;
  })();
}).call(this);
