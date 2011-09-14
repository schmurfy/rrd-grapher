(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  window.Serie = (function() {
    __extends(Serie, StaticLine);
    function Serie(rrd_path, ds_name, legend, yaxis, formatter, rra) {
      this.rrd_path = rrd_path;
      this.ds_name = ds_name;
      this.legend = legend;
      this.yaxis = yaxis != null ? yaxis : 1;
      this.formatter = formatter != null ? formatter : Format.identity;
      this.rra = rra != null ? rra : null;
      Serie.__super__.constructor.call(this, null, legend, yaxis, formatter);
      this.static = false;
    }
    Serie.prototype.get_definition = function() {
      return {
        data: this.data,
        label: this.legend,
        yaxis: this.yaxis,
        color: this.color
      };
    };
    return Serie;
  })();
}).call(this);
