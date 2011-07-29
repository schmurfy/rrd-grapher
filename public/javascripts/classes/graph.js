
function Graph(parent_container, formatters, limits){
  formatters = formatters || [Format.identity, Format.identity];
  limits = limits || [[null, null], [null, null]]
  
  this.maxrows = 400;
  
  this.legend_containers = [];
  this.formatters = formatters;
  
  // create graph container
  this.master_container = $("<div>").addClass("graph_container").appendTo(parent_container);
  this.legend_containers[0] = $("<div>").addClass('legend').appendTo(this.master_container);
  this.container = $("<div>").addClass("graph").appendTo(this.master_container);
  this.legend_containers[1] = $("<div>").addClass('legend').appendTo(this.master_container);
  
  this.series = [];
  this.lines = [];
  this.tooltip_point = null;
  
  // compute end date (now - 20s)
  this.to = Math.floor((new Date().getTime() / 1000) - 2);
  this.from = this.to - 30;
  
  this.plot = null;
  this.flot_options = {
      legend: { show : false },
      selection: { mode: 'x' },
      grid: { hoverable: true },
      xaxis: { mode: "time", show: true },
      yaxes: [
          {
            min: limits[0][0],
            max: limits[0][1],
            tickFormatter: formatters[0]
          },
          {
            min: limits[1][0],
            max: limits[1][1],
            position: "right",
            tickFormatter: formatters[1]
          }
        ]
    };
}

Graph.colors = ["#edc240", "#afd8f8", "#cb4b4b", "#4da74d", "#9440ed"];
Graph.next_color = 0;

$.extend(Graph.prototype, {
  getPath: function(){
    return this.rrd_path;
  },
  
  addSerie: function(rrd_path, ds_name, legend, yaxis, formatter){
    var yaxis = yaxis || 1;
    var formatter = formatter || this.formatters[yaxis - 1];
    
    var s = new Serie(rrd_path, ds_name, legend, yaxis, formatter);
    s.color = Graph.colors[Graph.next_color++];
    this.series.push(s);
  },
  
  addLine: function(yvalue, color){
    var l = new StaticLine(yvalue, color);
    this.lines.push(l);
  },
  
  create: function(){
    this.update_graph(true);
  },
  
  update_graph: function(first){
    first = first || false;
    var i;
    var self = this;
    
    var urls = [];
    
    $(this.series).each(function(i, s){
      if( s.enabled ){
        urls.push(["/rrd/" + s.rrd_path + "/values/" + self.from + "/" + self.to + "?maxrows=" + self.maxrows + "&ds_name=" + s.ds_name + "&rra=0", s]);
      }
    });
    
    this.multiple_get(urls, function(data_array){
      self._update_graph_common(first, data_array);
    });
    
  },
  
  update_graph_from_cache: function(){
    var data_array = [];
    
    $.each(this.series, function(i, s){
      if( s.enabled ){
        data_array.push( s.get_definition() );
      }
    });
    
    this._update_graph_common(false, data_array);
  },
  
  _update_graph_common: function(first, data_array){
    var self = this;
    
    // add static data
    $.each(this.lines, function(i, line){
      // console.log(this);
      data_array.push( line.get_definition(self.from, self.to) );
    });
    
    if( first ){
      this.plot = $.plot(this.container, data_array, this.flot_options);
      $(this.container).bind("plothover", function(event, pos, item){ self.show_tooltip(event, pos, item); });
      
      $(this.container).bind("plotselected", function(event, ranges) {
        debugger
        self.from = Math.floor(ranges.xaxis.from / 1000);
        self.to = Math.floor(ranges.xaxis.to / 1000);
        self.update_graph();
      });
      
    }
    else {
      this.plot.setData( data_array );
      this.plot.setupGrid();
      this.plot.draw();
    }
    
    var options = this.plot.getOptions();
    
    for(i= 0; i< this.series.length; i++){
      this.series[i].color = options.colors[i];
    }
      
    if( first ){
      this.create_legend(0);
      this.create_legend(1);
    }
  },
  
  
  
  multiple_get: function(urls, when_done_cb){
    var urls = $.makeArray(urls);
    var left = urls.length;
    var ret = [];
    var self = this;
    
    $(urls).each(function() {
      var url = this[0];
      var serie = this[1];
      
      $.getJSON(url, function(data) {
        serie.set_data(data);
        ret.push( serie.get_definition() );
        left -= 1;
        if(left == 0) when_done_cb(ret);
      });
    });
  },
  
  min: function(s){
    var ret = s.data[0][1];
    
    $.each(s.data, function(i, pair){
      if(pair[1] < ret){
        ret = pair[1];
      }
    })
    
    return ret;
  },
  
  max: function(s){
    var ret = s.data[0][1];
    
    $.each(s.data, function(i, pair){
      if(pair[1] > ret){
        ret = pair[1];
      }
    })
    
    return ret;
  },
  
  show_tooltip: function(event, pos, item){
    if (item) {
      var id = "" + item.seriesIndex + ":" + item.dataIndex;
      if( this.tooltip_point != id ){
        this.tooltip_point = id;
        // var s = this.series[item.seriesIndex];
        var s = $(this.series).filter(function(i, s){ return s.legend == item.series.label; }).first();
        if( s.length > 0 ) {
          s = s[0];
          $("#tooltip").remove();
          var y = item.datapoint[1];
          var item_date = new Date(item.datapoint[0]);
          var date_str = item_date.getHours() + ":" + item_date.getMinutes();
        
          var content = s.format(y) + '<br/>' + date_str + "<br/>" + s.legend;
        
          $('<div id="tooltip">' + content + '</div>').css( {
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
    }
    else {
      $("#tooltip").remove();
      this.tooltip_point = null;            
    }
  },
  
  create_legend: function(index){
    // placeholder.find(".legend").remove();
    // var series_data = this.plot.getData();
    var series = this.series;
    var self = this;

    var fragments = [], rowStarted = false, s, label, i;

    fragments.push("<tr><th></th><th>label</th><th>Min</th><th>Max</th></tr>");

    for( i= 0; i < series.length; i++) {
        s = series[i];
        label = s.legend;
        // debugger
        if( !label || (s.yaxis != (index + 1)) )
            continue;

        if (i % 1 == 0) {
            if (rowStarted)
                fragments.push('</tr>');
            fragments.push('<tr>');
            rowStarted = true;
        }

        // if (lf)
        //     label = lf(label, s);
        
        fragments.push(
            '<td data-serie="' + i + '" class="legendColorBox"><div class="outerBorder"><div style="width:4px;height:0;border:5px solid ' + s.color + ';overflow:hidden"></div></div></td>');
        
        fragments.push('<td class="legendLabel">' + label + '</td>');
        fragments.push('<td>' + s.format( this.min(s) ) +'</td>');
        fragments.push('<td>' + s.format( this.max(s) ) +'</td>');
    }

    if (rowStarted)
        fragments.push('</tr>');

    if (fragments.length == 0)
        return;

    var table = '<table style="font-size:smaller;color:#545454">' + fragments.join("") + '</table>';
    this.legend_containers[index].html(table);
    
    $(this.legend_containers[index]).find(".legendColorBox").click(function(){
      var id = $(this).attr("data-serie");
      var s = self.series[id];
      
      s.toggle_enabled();
      s.set_legend_color(this);
      self.update_graph_from_cache();
    });
  }
  
});

