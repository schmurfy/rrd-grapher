function StaticLine(yvalue, color){
  this.yvalue = yvalue;
  this.color = color;
}

$.extend(StaticLine.prototype, {
  get_definition: function(from, to){
    return {
        data: [
            [this.convert_time(from), this.yvalue],
            [this.convert_time(to), this.yvalue]
          ],
        legend: "",
        color: this.color
      };
  },
  
  convert_time: function(t){
    return (parseInt(t) + tz_offset*60) * 1000;
  }
  
});



function Serie(rrd_path, ds_name, legend, yaxis, formatter){
  this.rrd_path = rrd_path;
  this.ds_name = ds_name;
  this.legend = legend;
  this.enabled = true;
  this.yaxis = yaxis || 1;
  this.formatter = formatter || Format.identity;
  this.color = 'black';
}

$.extend(Serie.prototype, {
  
  set_legend_color: function(element){
    var tr = $(element).parent();
    
    if( this.enabled ){
      tr.removeClass('transparent');
    }
    else {
      tr.addClass('transparent');
    }
  },
  
  set_enabled: function(new_state){
    if( new_state != this.enabled ){
      this.enabled = new_state;
    }
  },
  
  toggle_enabled : function(){
    var new_state;
    
    if( this.enabled ){
      new_state = false;
    }
    else {
      new_state = true;
    }
    
    this.set_enabled(new_state);
  },
  
  get_definition: function(){
    return {
        data: this.data,
        label: this.legend,
        yaxis: this.yaxis,
        color: this.color
      };
  },
  
  convert_time: function(t){
    return (parseInt(t) + tz_offset*60) * 1000;
  },
  
  get_data: function(){
    return this.data;
  },
  
  set_data: function(data){
    this.data = [];
    var self = this;
    
    $.each(data, function(t, v){
      self.data.push( [self.convert_time(t), v] );
    });
  },
  
  format: function(v){
    return this.formatter(v);
  }
  
});

