(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __slice = Array.prototype.slice, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.GraphController = (function() {
    __extends(GraphController, Backbone.View);
    function GraphController() {
      GraphController.__super__.constructor.apply(this, arguments);
    }
    GraphController.prototype.initialize = function() {
      return this.pages = this.options.pages;
    };
    return GraphController;
  })();
  window.GraphPage = (function() {
    function GraphPage(container, panel_container, host) {
      this.container = container;
      this.panel_container = panel_container;
      this.host = host;
      this.graphs = [];
      this.autorefresh_timer = null;
      this.autorefresh_checkbox = $("#autorefresh", this.panel_container);
      this.linked_zoom_checkbox = $("#linkedzoom", this.panel_container);
      this.offset = 60 * 1000;
    }
    GraphPage.prototype.addGraph = function() {
      var args, class_name, g;
      class_name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      g = (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(window[class_name], [this.container, this.host].concat(__slice.call(args)), function() {});
      g.init();
      g.bind("dblclick", __bind(function() {
        this.set_simple_interval(this.interval);
        return this.set_autorefresh(null);
      }, this));
      g.bind("plotselection", __bind(function(from, to) {
        this.set_autorefresh(null);
        if (this.linked_zoom_checkbox.attr("checked")) {
          return this.set_interval(from, to);
        }
      }, this));
      return this.graphs.push(g);
    };
    GraphPage.prototype.set_simple_interval = function(interval) {
      var from, to;
      this.interval = interval;
      to = (new Date().getTime()) - this.offset;
      to = to / 1000;
      from = to - interval;
      return this.set_interval(from, to);
    };
    GraphPage.prototype.set_interval = function(from, to) {
      return $.each(this.graphs, function(i, g) {
        g.set_interval(from, to);
        return g.update_graph();
      });
    };
    GraphPage.prototype.set_autorefresh = function(time) {
      if (this.autorefresh_timer) {
        window.clearInterval(this.autorefresh_timer);
        this.autorefresh_timer = null;
      }
      if (time) {
        this.autorefresh_checkbox.attr("checked", true);
        return this.autorefresh_timer = window.setInterval((__bind(function() {
          return this.set_simple_interval(this.interval);
        }, this)), time);
      } else {
        return this.autorefresh_checkbox.attr("checked", false);
      }
    };
    GraphPage.prototype.refresh = function() {
      return this.set_simple_interval(this.interval);
    };
    return GraphPage;
  })();
  window.GraphDefinition = (function() {
    function GraphDefinition(host, container, title, formatters, ymin) {
      var limits;
      this.host = host;
      this.container = container;
      this.title = title;
      _.extend(this, Backbone.Events);
      if (ymin) {
        limits = $.map(formatters, function() {
          return [[0, ymin]];
        });
      } else {
        limits = null;
      }
      this.graph = new Graph({
        "title": this.title,
        "parent_container": this.container,
        "formatters": formatters,
        "limits": limits
      });
      this.graph.bind("dblclick", __bind(function() {
        return this.trigger("dblclick");
      }, this));
      this.graph.bind("plotselection", __bind(function(from, to) {
        return this.trigger("plotselection", from, to);
      }, this));
    }
    GraphDefinition.prototype.init = function() {
      return this.graph.create();
    };
    GraphDefinition.prototype.set_interval = function(from, to) {
      return this.graph.set_interval(from, to);
    };
    GraphDefinition.prototype.update_graph = function() {
      return this.graph.update_graph();
    };
    return GraphDefinition;
  })();
  window.NetworkGraph = (function() {
    __extends(NetworkGraph, GraphDefinition);
    function NetworkGraph(container, host, interface, ymin) {
      this.interface = interface;
      if (ymin == null) {
        ymin = null;
      }
      NetworkGraph.__super__.constructor.call(this, host, container, "Network Traffic (" + interface + ")", [Format.size, Format.size], ymin);
      this.graph.addSerie("" + this.host + "/interface/if_octets-" + this.interface, "rx", "(" + this.interface + ") Bytes Received");
      this.graph.addSerie("" + this.host + "/interface/if_octets-" + this.interface, "tx", "(" + this.interface + ") Bytes Sent");
      this.graph.create();
    }
    return NetworkGraph;
  })();
  window.MemoryGraph = (function() {
    __extends(MemoryGraph, GraphDefinition);
    function MemoryGraph(container, host, ymin) {
      if (ymin == null) {
        ymin = null;
      }
      MemoryGraph.__super__.constructor.call(this, host, container, "Memory", [Format.size, Format.size], ymin);
      this.graph.addSerie("" + this.host + "/memory/memory-active", "value", "Active");
      this.graph.addSerie("" + this.host + "/memory/memory-free", "value", "Free");
      this.graph.addSerie("" + this.host + "/memory/memory-inactive", "value", "Inactive");
      this.graph.addSerie("" + this.host + "/memory/memory-wired", "value", "Wired");
    }
    return MemoryGraph;
  })();
  window.LoadGraph = (function() {
    __extends(LoadGraph, GraphDefinition);
    function LoadGraph(container, host, ymin) {
      if (ymin == null) {
        ymin = null;
      }
      LoadGraph.__super__.constructor.call(this, host, container, "CPU Load", [Format.size, Format.size], ymin);
      this.graph.addSerie("" + this.host + "/load/load", "shortterm", "Load (1min)");
      this.graph.addSerie("" + this.host + "/load/load", "midterm", "Load (5min)");
      this.graph.addSerie("" + this.host + "/load/load", "longterm", "Load (15min)");
    }
    return LoadGraph;
  })();
}).call(this);
