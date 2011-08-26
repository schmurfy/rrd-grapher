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
      this.date_select = $("#dateselect", this.panel_container);
      this.interval = 15 * 60;
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
      this.date_select.val("");
      to = (new Date().getTime()) - this.offset;
      to = to / 1000;
      from = to - this.interval;
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
        ymin = $.makeArray(ymin);
        if (ymin.length === 1) {
          limits = $.map(formatters, function() {
            return [[0, ymin[0]]];
          });
        } else if (ymin.length === 2) {
          limits = $.map(ymin, function(val) {
            return [[0, val]];
          });
        }
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
  window.NTPGraph = (function() {
    __extends(NTPGraph, GraphDefinition);
    function NTPGraph(container, host, remote_host, ymin) {
      this.remote_host = remote_host;
      if (ymin == null) {
        ymin = null;
      }
      NTPGraph.__super__.constructor.call(this, host, container, "NTP", [Format.delay, Format.identity], ymin);
      this.graph.addSerie("" + this.host + "/ntpd/time_offset-" + this.remote_host, "seconds", "Offset remote");
      this.graph.addSerie("" + this.host + "/ntpd/time_offset-loop", "seconds", "Offset local");
      this.graph.addSerie("" + this.host + "/ntpd/delay-" + this.remote_host, "seconds", "Delay remote");
      this.graph.addSerie("" + this.host + "/ntpd/time_dispersion-" + this.remote_host, "seconds", "Dispertion remote");
      this.graph.addSerie("" + this.host + "/ntpd/time_dispersion-LOCAL", "seconds", "Dispertion local");
    }
    return NTPGraph;
  })();
  window.CPUGraph = (function() {
    __extends(CPUGraph, GraphDefinition);
    function CPUGraph(container, host, cpu_index, ymin) {
      this.cpu_index = cpu_index;
      if (ymin == null) {
        ymin = null;
      }
      CPUGraph.__super__.constructor.call(this, host, container, "CPU " + this.cpu_index, [Format.percent, Format.prcent], ymin);
      this.graph.addSerie("" + this.host + "/cpu-" + this.cpu_index + "/cpu-user", 'value', 'User');
      this.graph.addSerie("" + this.host + "/cpu-" + this.cpu_index + "/cpu-system", 'value', 'System');
      this.graph.addSerie("" + this.host + "/cpu-" + this.cpu_index + "/cpu-interrupt", 'value', 'Interrupt');
    }
    return CPUGraph;
  })();
  window.DFGraph = (function() {
    __extends(DFGraph, GraphDefinition);
    function DFGraph(container, host, location, ymin) {
      this.location = location;
      if (ymin == null) {
        ymin = null;
      }
      DFGraph.__super__.constructor.call(this, host, container, "Disk use (" + this.location + ")", [Format.size, Format.size], ymin);
      this.graph.addSerie("" + this.host + "/df/df-" + this.location, 'used', 'Used');
      this.graph.addSerie("" + this.host + "/df/df-" + this.location, 'free', 'Free');
    }
    return DFGraph;
  })();
  window.PingGraph = (function() {
    __extends(PingGraph, GraphDefinition);
    function PingGraph(container, host, label, destination, ymin) {
      this.label = label;
      this.destination = destination;
      if (ymin == null) {
        ymin = null;
      }
      PingGraph.__super__.constructor.call(this, host, container, "Ping " + this.label, [Format.delay, Format.identity], ymin);
      this.graph.addSerie("" + this.host + "/ping/ping-" + this.destination, 'ping', 'Latency');
      this.graph.addSerie("" + this.host + "/ping/ping_stddev-" + this.destination, 'value', 'stddev');
      this.graph.addSerie("" + this.host + "/ping/ping_droprate-" + this.destination, 'value', 'Loss', 2);
    }
    return PingGraph;
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
    }
    return NetworkGraph;
  })();
  window.MemoryGraph = (function() {
    __extends(MemoryGraph, GraphDefinition);
    function MemoryGraph(container, host, os, ymin) {
      if (ymin == null) {
        ymin = null;
      }
      MemoryGraph.__super__.constructor.call(this, host, container, "Memory", [Format.size, Format.size], ymin);
      if (os === "freebsd") {
        this.graph.addSerie("" + this.host + "/memory/memory-active", "value", "Active");
        this.graph.addSerie("" + this.host + "/memory/memory-cache", "value", "Cached");
        this.graph.addSerie("" + this.host + "/memory/memory-free", "value", "Free");
        this.graph.addSerie("" + this.host + "/memory/memory-inactive", "value", "Inactive");
        this.graph.addSerie("" + this.host + "/memory/memory-wired", "value", "Wired");
      } else if (os === "linux") {
        this.graph.addSerie("" + this.host + "/memory/memory-buffered", "value", "Buffered");
        this.graph.addSerie("" + this.host + "/memory/memory-cached", "value", "Caached");
        this.graph.addSerie("" + this.host + "/memory/memory-free", "value", "Free");
        this.graph.addSerie("" + this.host + "/memory/memory-used", "value", "Used");
      }
    }
    return MemoryGraph;
  })();
  window.LoadGraph = (function() {
    __extends(LoadGraph, GraphDefinition);
    function LoadGraph(container, host, ymin) {
      if (ymin == null) {
        ymin = null;
      }
      LoadGraph.__super__.constructor.call(this, host, container, "CPU Load", [Format.identity, Format.identity], ymin);
      this.graph.addSerie("" + this.host + "/load/load", "shortterm", "Load (1min)");
      this.graph.addSerie("" + this.host + "/load/load", "midterm", "Load (5min)");
      this.graph.addSerie("" + this.host + "/load/load", "longterm", "Load (15min)");
    }
    return LoadGraph;
  })();
  window.MonitoringDriftGraph = (function() {
    __extends(MonitoringDriftGraph, GraphDefinition);
    function MonitoringDriftGraph(container, host, ymin) {
      if (ymin == null) {
        ymin = null;
      }
      MonitoringDriftGraph.__super__.constructor.call(this, host, container, "Clock drift", [Format.delay, Format.delay], ymin);
      this.graph.addSerie("" + this.host + "/monitoring/gauge-clock_drift", "value", "Drift");
    }
    return MonitoringDriftGraph;
  })();
}).call(this);
