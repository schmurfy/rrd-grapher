
Format = {
  speed: function(num){
    return Format._convert(num, 1024, ["", "KB/s", "MB/s", "GB/s"]);
  },
  
  size: function(num){
    return Format._convert(num, 1024, ["", "KB", "MB", "GB"]);
  },
  
  delay: function(num){
    if( num < 1000 ){
      return "" + num + "&nbsp;ms";
    }
    else {
      return Format._convert(num/1000, 60, ["", "KB", "MB", "GB"]);
    }
  },
  
  
  identity: function(num){
    return num;
  },
  
  _convert: function(num, ref, units){
    var index = 0;

    while( num > ref ){
      num /= ref;
      index+= 1;
    }

    return "" +  parseFloat(num).toFixed(2) + "&nbsp;" + units[index];
  }
}


