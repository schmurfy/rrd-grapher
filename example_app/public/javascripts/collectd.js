(function() {
  var CollectdPage;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  CollectdPage = (function() {
    __extends(CollectdPage, GraphPage);
    function CollectdPage(container, host) {
      CollectdPage.__super__.constructor.call(this, container, host);
      this.addGraph("NetworkGraph", "en0", 1 * Size.megabyte);
      this.addGraph("NetworkGraph", "en1", 1 * Size.megabyte);
      this.addGraph("MemoryGraph");
      this.addGraph("LoadGraph", 2.0);
    }
    return CollectdPage;
  })();
  $(function() {
    var container, graphs, page;
    graphs = [];
    $('#toggle_config').click(function() {
      return $("#config_panel").fadeToggle();
    });
    container = $("#graphs");
    page = new CollectdPage(container, "pomme.local");
    page.refresh(30);
    return $("#rangeselect").chosen().change(function() {
      return page.refresh($(this).val());
    });
  });
}).call(this);
