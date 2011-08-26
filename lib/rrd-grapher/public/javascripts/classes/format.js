(function() {
  window.Format = {
    speed: function(num) {
      return Format._convert(num, 1024, ["B/s", "KB/s", "MB/s", "GB/s"]);
    },
    size: function(num) {
      return Format._convert(num, 1024, ["B", "KB", "MB", "GB"]);
    },
    percent: function(num) {
      return Format._convert(num, null, ["%"]);
    },
    delay: function(num) {
      if (num < 1000) {
        return Format._convert(num, null, ["ms"]);
      } else {
        return Format._convert(num / 1000, 60, ["s", "m", "h"]);
      }
    },
    identity: function(num) {
      return Format._convert(num);
    },
    _convert: function(num, ref, units) {
      var abs_num, index, sign;
      if (ref == null) {
        ref = null;
      }
      if (units == null) {
        units = [""];
      }
      index = 0;
      sign = num < 0 ? -1 : 1;
      abs_num = Math.abs(num);
      if (ref) {
        while (abs_num > ref) {
          abs_num /= ref;
          index += 1;
        }
      }
      return "" + parseFloat(abs_num * sign).toFixed(2) + "&nbsp;" + units[index];
    }
  };
}).call(this);
