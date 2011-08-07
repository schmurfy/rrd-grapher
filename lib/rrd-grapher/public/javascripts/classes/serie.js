(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.Serie = (function() {
    function Serie(rrd_path, ds_name, legend, yaxis, formatter, rra) {
      this.rrd_path = rrd_path;
      this.ds_name = ds_name;
      this.legend = legend;
      this.yaxis = yaxis != null ? yaxis : 1;
      this.formatter = formatter != null ? formatter : Format.identity;
      this.rra = rra != null ? rra : null;
      this.enabled = true;
      this.color = 'black';
      this.data = [];
    }
    Serie.prototype.set_legend_color = function(element) {
      var tr;
      tr = $(element).parent();
      if (this.enabled) {
        return tr.removeClass('transparent');
      } else {
        return tr.addClass('transparent');
      }
    };
    Serie.prototype.set_enabled = function(new_state) {
      return this.enabled = new_state;
    };
    Serie.prototype.toggle_enabled = function() {
      var new_state;
      new_state = !this.enabled;
      return this.set_enabled(new_state);
    };
    Serie.prototype.get_definition = function() {
      return {
        data: this.data,
        label: this.legend,
        yaxis: this.yaxis,
        color: this.color
      };
    };
    Serie.prototype.get_data = function() {
      return this.data;
    };
    Serie.prototype.set_data = function(data) {
      this.data = [];
      return $.each(data, __bind(function(t, v) {
        return this.data.push([Time.server_to_client(t), v]);
      }, this));
    };
    Serie.prototype.format = function(v) {
      return this.formatter(v);
    };
    return Serie;
  })();
}).call(this);
