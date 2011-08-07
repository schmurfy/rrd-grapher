
window.Time =
  # getTimezoneOffset() returns local offset in hours
  tz_offset: 60 * -( new Date() ).getTimezoneOffset()
  
  local_to_utc: (timestamp) ->
    parseInt(timestamp, 10) - Time.tz_offset
  
  utc_to_local: (timestamp) ->
    parseInt(timestamp, 10) + Time.tz_offset
  
  server_to_client: (timestamp) ->
    @utc_to_local(timestamp) * 1000
  
  client_to_server: (timestamp) ->
    Math.floor( @local_to_utc(timestamp / 1000) )
  
