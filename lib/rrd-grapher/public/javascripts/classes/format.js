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
      var index;
      if (ref == null) {
        ref = null;
      }
      if (units == null) {
        units = [""];
      }
      index = 0;
      if (ref) {
        while (num > ref) {
          num /= ref;
          index += 1;
        }
      }
      return "" + parseFloat(num).toFixed(2) + "&nbsp;" + units[index];
    }
  };
}).call(this);
