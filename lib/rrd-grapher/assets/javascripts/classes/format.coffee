
window.Format =
  speed: (num) ->
    Format._convert(num, 1024, ["", "KB/s", "MB/s", "GB/s"])
  
  size: (num) ->
    Format._convert(num, 1024, ["", "KB", "MB", "GB"])
  
  delay: (num) ->
    if num < 1000
      "" + num + "&nbsp;ms"
    else
      Format._convert(num/1000, 60, ["s", "m", "h"])
  
  
  identity: (num) ->
    num
  
  _convert: (num, ref, units) ->
    index = 0

    while num > ref
      num /= ref
      index+= 1

    "" +  parseFloat(num).toFixed(2) + "&nbsp;" + units[index]


