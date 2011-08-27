(function() {
  var CollectdPage;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  window.TestGraph = (function() {
    __extends(TestGraph, GraphDefinition);
    function TestGraph(container, host, interface, ymin) {
      this.interface = interface;
      if (ymin == null) {
        ymin = null;
      }
      TestGraph.__super__.constructor.call(this, host, container, "Test Traffic (" + interface + ")", [Format.size, Format.size], ymin);
      this.graph.addSerie("" + this.host + "/interface/if_octets-" + this.interface, "rx", "(" + this.interface + ") Bytes Received");
      this.graph.addSerie("" + this.host + "/interface/if_octets-" + this.interface, "tx", "(" + this.interface + ") Bytes Sent", 2);
    }
    return TestGraph;
  })();
  CollectdPage = (function() {
    __extends(CollectdPage, GraphPage);
    function CollectdPage(container, panel_container, host) {
      CollectdPage.__super__.constructor.call(this, container, panel_container, host);
      this.addGraph("TestGraph", "en1", [20 * Size.kilobyte, 100 * Size.kilobyte]);
      this.addGraph("MemoryGraph", "osx");
      this.addGraph("LoadGraph", 2.0);
    }
    return CollectdPage;
  })();
  $(function() {
    var container, graphs, page, panel_container;
    graphs = [];
    container = $("#graphs");
    panel_container = $("#config_panel");
    page = new CollectdPage(container, panel_container, "pomme.local");
    $("#dateselect").datepicker().change(function() {
      var date_string, time;
      date_string = $(this).val();
      time = Date.parse(date_string) / 1000;
      page.set_autorefresh(null);
      return page.set_interval(time, time + 24 * 60 * 60);
    });
    $("#rangeselect").chosen().change(function() {
      page.set_autorefresh(null);
      return page.set_simple_interval($(this).val());
    });
    $("#linkedzoom").change(__bind(function(event) {
      if ($(event.currentTarget).attr("checked")) {
        return page.refresh();
      }
    }, this));
    return $("#autorefresh").change(__bind(function(event) {
      if ($(event.currentTarget).attr("checked")) {
        return page.set_autorefresh(5000);
      } else {
        return page.set_autorefresh(null);
      }
    }, this));
  });
}).call(this);
