(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.Graph = (function() {
    var colors, next_color;
    __extends(Graph, Backbone.Model);
    function Graph() {
      Graph.__super__.constructor.apply(this, arguments);
    }
    colors = ["#edc240", "#afd8f8", "#cb4b4b", "#4da74d", "#9440ed"];
    next_color = 0;
    Graph.prototype.defaults = {
      "formatters": [Format.identity, Format.identity],
      "limits": [[null, null], [null, null]]
    };
    Graph.prototype.initialize = function() {
      var master_container, parent_container, title, to;
      this.set({
        "maxrows": 400
      });
      this.set({
        "legend_containers": []
      });
      parent_container = this.get("parent_container");
      title = this.get("title");
      if (this.get("limits") === null) {
        this.set({
          "limits": this.defaults["limits"]
        });
      }
      master_container = $("<div>").addClass("graph_container").appendTo(parent_container);
      this.set({
        "master_container": master_container
      });
      this.get("legend_containers")[0] = $("<div>").addClass('legend').appendTo(master_container);
      $("<h3>").text(title).appendTo(this.get("legend_containers")[0]);
      $("<div>").appendTo(this.get("legend_containers")[0]);
      this.set({
        "container": $("<div>").addClass("graph").appendTo(master_container)
      });
      this.set({
        "series": []
      });
      this.set({
        "lines": []
      });
      this.set({
        "tooltip_point": null
      });
      to = Math.floor((new Date().getTime() / 1000) - 20);
      this.set({
        "to": to
      });
      this.set({
        "from": to - 30
      });
      this.set({
        "plot": null
      });
      return this.set({
        "flot_options": {
          "legend": {
            show: false
          },
          "selection": {
            mode: 'x'
          },
          "grid": {
            hoverable: true
          },
          "xaxis": {
            mode: "time",
            show: true
          },
          "yaxes": [
            {
              "min": this.get("limits")[0][0],
              "max": this.get("limits")[0][1],
              "tickFormatter": this.get("formatters")[0],
              "labelWidth": 100
            }, {
              "min": this.get("limits")[1][0],
              "max": this.get("limits")[1][1],
              "position": "right",
              "labelWidth": 100,
              "reserveSpace": true,
              "tickFormatter": this.get("formatters")[1]
            }
          ]
        }
      });
    };
    Graph.prototype.addSerie = function(rrd_path, ds_name, legend, yaxis, formatter) {
      var s;
      yaxis = yaxis || 1;
      formatter = formatter || this.get("formatters")[yaxis - 1];
      s = new Serie(rrd_path, ds_name, legend, yaxis, formatter);
      s.color = colors[next_color++];
      return this.get("series").push(s);
    };
    Graph.prototype.addLine = function(yvalue, color) {
      var l;
      l = new StaticLine(yvalue, color);
      return this.get("lines").push(l);
    };
    Graph.prototype.create = function() {
      this.update_graph(true);
      return this;
    };
    Graph.prototype._build_query = function(s) {
      var query;
      query = "/rrd/" + s.rrd_path + "/values/" + (this.get('from')) + "/" + (this.get('to')) + "?maxrows=" + (this.get('maxrows')) + "&ds_name=" + s.ds_name;
      if (s.rra) {
        query += "&rra=" + s.rra;
      }
      return query;
    };
    Graph.prototype.update_graph = function(first) {
      var urls;
      first = first || false;
      urls = [];
      urls = $(this.get("series")).select(function(s) {
        return s.enabled;
      }).map(__bind(function(i, s) {
        return [[this._build_query(s), s]];
      }, this));
      return this.multiple_get(urls, __bind(function(data_array) {
        return this._update_graph_common(first, data_array);
      }, this));
    };
    Graph.prototype.update_graph_from_cache = function() {
      var data_array;
      data_array = [];
      $.each(this.get("series"), function(i, s) {
        if (s.enabled) {
          return data_array.push(s.get_definition());
        }
      });
      return this._update_graph_common(false, data_array);
    };
    Graph.prototype.set_interval = function(from, to) {
      this.set({
        "from": from
      });
      return this.set({
        "to": to
      });
    };
    Graph.prototype._update_graph_common = function(first, data_array) {
      var container, i, options, plot, _ref;
      $.each(this.get("lines"), function(i, line) {
        return data_array.push(line.get_definition(this.get("from"), this.get("to")));
      });
      if (first) {
        this.set({
          "plot": $.plot(this.get("container"), data_array, this.get("flot_options"))
        });
        container = this.get("container");
        container.bind("plothover", __bind(function(event, pos, item) {
          return this.show_tooltip(event, pos, item);
        }, this));
        container.bind("plotselected", __bind(function(event, ranges) {
          var from, to;
          from = Time.client_to_server(ranges.xaxis.from);
          to = Time.client_to_server(ranges.xaxis.to);
          this.set_interval(from, to);
          this.trigger("plotselection", from, to);
          this.update_graph();
          return this.get("plot").clearSelection();
        }, this));
        container.dblclick(__bind(function() {
          return this.trigger("dblclick");
        }, this));
      } else {
        plot = this.get("plot");
        plot.setData(data_array);
        plot.setupGrid();
        plot.draw();
      }
      options = this.get("plot").getOptions();
      for (i = 0, _ref = this.get("series").length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        this.get("series")[i].color = options.colors[i];
      }
      return this.create_legend(0);
    };
    Graph.prototype.multiple_get = function(urls, when_done_cb) {
      var left, ret;
      urls = $.makeArray(urls);
      left = urls.length;
      ret = [];
      return $(urls).each(function(i, el) {
        var serie, url;
        url = el[0];
        serie = el[1];
        return $.getJSON(url, function(data) {
          serie.set_data(data);
          ret.push(serie.get_definition());
          left -= 1;
          if (left === 0) {
            return when_done_cb(ret);
          }
        });
      });
    };
    Graph.prototype.avg = function(s) {
      var count, ret;
      ret = 0;
      count = 0;
      $.each(s.data, function(i, pair) {
        ret += pair[1];
        return count++;
      });
      return ret / count;
    };
    Graph.prototype.min = function(s) {
      var ret;
      ret = null;
      $.each(s.data, function(i, pair) {
        if (pair[1] && !isNaN(pair[1]) && (!ret || (pair[1] < ret))) {
          return ret = pair[1];
        }
      });
      return ret;
    };
    Graph.prototype.max = function(s) {
      var ret;
      ret = null;
      $.each(s.data, function(i, pair) {
        if (pair[1] && !isNaN(pair[1]) && (!ret || (pair[1] > ret))) {
          return ret = pair[1];
        }
      });
      return ret;
    };
    Graph.prototype.show_tooltip = function(event, pos, item) {
      var content, date_str, id, item_date, s, y;
      if (item) {
        id = "" + item.seriesIndex + ":" + item.dataIndex;
        if (this.get("tooltip_point") !== id) {
          this.set({
            "tooltip_point": id
          });
          s = $(this.get("series")).filter(function(i, s) {
            return s.legend === item.series.label;
          }).first();
          if (s.length > 0) {
            s = s[0];
            $("#tooltip").remove();
            y = item.datapoint[1];
            item_date = new Date(item.datapoint[0]);
            date_str = item_date.getHours() + ":" + item_date.getMinutes();
            content = s.format(y) + '<br/>' + date_str + "<br/>" + s.legend;
            return $('<div id="tooltip">' + content + '</div>').css({
              position: 'absolute',
              display: 'none',
              top: item.pageY - 5,
              left: item.pageX + 15,
              border: '1px solid #fdd',
              padding: '2px',
              'background-color': '#fee',
              opacity: 0.80
            }).appendTo("body").fadeIn(200);
          }
        }
      } else {
        $("#tooltip").remove();
        return this.set({
          "tooltip_point": null
        });
      }
    };
    Graph.prototype.create_legend = function(index) {
      var fragments, i, label, rowStarted, s, series, table, _ref;
      series = this.get("series");
      fragments = [];
      rowStarted = false;
      fragments.push("<tr><th></th><th>label</th><th>Avg</th><th>Min</th><th>Max</th></tr>");
      for (i = 0, _ref = series.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        s = series[i];
        label = s.legend;
        if (!label) {
          continue;
        }
        if (i % 1 === 0) {
          if (rowStarted) {
            fragments.push('</tr>');
          }
          fragments.push('<tr>');
          rowStarted = true;
        }
        fragments.push('<td data-serie="' + i + '" class="legendColorBox"><div class="outerBorder"><div style="width:4px;height:0;border:5px solid ' + s.color + ';overflow:hidden"></div></div></td>');
        fragments.push('<td class="legendLabel">' + label + '</td>');
        fragments.push("<td>" + (s.format(this.avg(s))) + "</td>");
        fragments.push("<td>" + (s.format(this.min(s))) + "</td>");
        fragments.push("<td>" + (s.format(this.max(s))) + "</td>");
      }
      if (rowStarted) {
        fragments.push('</tr>');
      }
      if (fragments.length === 0) {
        return;
      }
      table = '<table style="font-size:smaller;color:#545454">' + fragments.join("") + '</table>';
      this.get("legend_containers")[index].find("div").html(table);
      return this.get("legend_containers")[index].find(".legendColorBox").click(__bind(function(event) {
        var id, target;
        target = event.currentTarget;
        id = $(target).attr("data-serie");
        s = this.get("series")[id];
        s.toggle_enabled();
        s.set_legend_color(target);
        return this.update_graph_from_cache();
      }, this));
    };
    return Graph;
  })();
}).call(this);