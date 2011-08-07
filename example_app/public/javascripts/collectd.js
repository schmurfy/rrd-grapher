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
  CollectdPage = (function() {
    __extends(CollectdPage, GraphPage);
    function CollectdPage(container, panel_container, host) {
      CollectdPage.__super__.constructor.call(this, container, panel_container, host);
      this.addGraph("NetworkGraph", "en0", 1 * Size.megabyte);
      this.addGraph("NetworkGraph", "en1", 1 * Size.megabyte);
      this.addGraph("MemoryGraph");
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
    page.set_simple_interval(30);
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
