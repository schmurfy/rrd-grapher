
describe "Time", ->
  beforeEach ->
    # fake a 10 seconds offset
    Time.tz_offset = 10
  
  
  it "can convert Time From UTC to local", ->
    time = 100
    utc_time = Time.utc_to_local(time)
    expect(utc_time).toEqual( 110 )
  
  it "can convert Time From local to UTC", ->
    time = 100
    utc_time = Time.local_to_utc(time)
    expect(utc_time).toEqual( 90 )
  
  it "can convert Client timestamp to Server timestamp", ->
    client_time = 100 * 1000
    server_time = Time.client_to_server(client_time)
    expect(server_time).toEqual(90)

  it "can convert Server timestamp to Client timestamp", ->
    server_time = 90
    client_time = Time.server_to_client(server_time)
    expect(client_time).toEqual(100 * 1000)