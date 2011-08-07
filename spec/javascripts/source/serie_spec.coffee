
describe "Serie", ->
  beforeEach ->
    @serie = new Serie("/rrd/path", "ds_name", "Serie Name")
  
  it "should be enabled by default", ->
    expect(@serie.enabled).toEqual(true)
  
  it "should return its definition", ->
    expected_def = {
        data: [],
        label: "Serie Name",
        yaxis: 1,
        color: 'black'
      }
    expect(@serie.get_definition()).toEqual(expected_def)
  
  it "should allow toggling its enable state", ->
    @serie.toggle_enabled()
    expect(@serie.enabled).toEqual(false)
    @serie.toggle_enabled()
    expect(@serie.enabled).toEqual(true)
  
  it "should allow directly setting its enable state", ->
    @serie.set_enabled(false)
    expect(@serie.enabled).toEqual(false)
    @serie.set_enabled(true)
    expect(@serie.enabled).toEqual(true)
