
describe "NetworkGraph", ->
  beforeEach ->
    container = $('<div>')
    @def = new NetworkGraph(container, "test.com", "en0")
  
  it "should initialize correctly", ->
    series = @def.graph.get("series")
    expect(series.length).toEqual(2)
    expect(series[0].rrd_path).toEqual("test.com/interface/if_octets-en0")
    expect(series[1].rrd_path).toEqual("test.com/interface/if_octets-en0")

describe "GraphPage", ->
  beforeEach ->
    @container = $('<div>')
    @page = new GraphPage(@container, "test.com")
  
  it "can be created", ->
    expect(@page.graphs).toEqual([])
  
  it "can include graph definitions", ->
    @page.addGraph("NetworkGraph", "en0")
    expect(@page.graphs.length).toEqual(1)
    expect(@page.graphs[0]).toEqual(jasmine.any(Object))
    # check object "class", the should be a more straight forward way to do this...
    expect(@page.graphs[0].constructor.prototype).toBe( (new NetworkGraph("a1")).constructor.prototype )
  
