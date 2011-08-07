(function() {
  window.Time = {
    tz_offset: 60 * -(new Date()).getTimezoneOffset(),
    local_to_utc: function(timestamp) {
      return parseInt(timestamp, 10) - Time.tz_offset;
    },
    utc_to_local: function(timestamp) {
      return parseInt(timestamp, 10) + Time.tz_offset;
    },
    server_to_client: function(timestamp) {
      return this.utc_to_local(timestamp) * 1000;
    },
    client_to_server: function(timestamp) {
      return Math.floor(this.local_to_utc(timestamp / 1000));
    }
  };
}).call(this);
