
window.Format =
  speed: (num) ->
    Format._convert(num, 1024, ["B/s", "KB/s", "MB/s", "GB/s"])
  
  size: (num) ->
    Format._convert(num, 1024, ["B", "KB", "MB", "GB"])
  
  percent: (num) ->
    Format._convert(num, null, ["%"])
  
  delay: (num) ->
    if num < 1000
      Format._convert(num, null, ["ms"])
    else
      Format._convert(num/1000, 60, ["s", "m", "h"])
  
  
  identity: (num) ->
    Format._convert(num)
  
  _convert: (num, ref = null, units = [""]) ->
    index = 0

    sign = if num < 0 then -1 else 1
    abs_num = Math.abs(num)
    
    if ref
      while abs_num > ref
        abs_num /= ref
        index+= 1
    
    "" +  parseFloat(abs_num * sign).toFixed(2) + "&nbsp;" + units[index]


