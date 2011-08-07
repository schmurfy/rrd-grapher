
describe "Graph", ->
  beforeEach ->
    @container = $("<div>")
    @graph = new Graph("Graph Title", @container, null, null)
  
  it "should create required children", ->
    expect(@container).toContain("div.graph_title")
    expect(@container).toContain("div.graph_container")
    expect(@container).toContain("div.legend")
    expect(@container).toContain("div.graph")
  
  it "should allow adding serie", ->
    expect(@graph.get("series").length).toEqual(0)
    create_spy = spyOn(window, "Serie")
    @graph.addSerie("path/to/file.rrd", "my_ds", "legend_text", 1, null)
    expect(@graph.get("series").length).toEqual(1)
    # expect(create_spy).toHaveBeenCalledWith(["path/to/file.rrd", "my_ds", "legend_text", 1w, jasmine.any(Function)])
  
  it "should allow addingd static lines", ->
    expect(@graph.get("lines").length).toEqual(0)
    @graph.addLine(13, "red")
    expect(@graph.get("lines").length).toEqual(1)
  
  it "should update its view when created", ->
    update_spy = spyOn(@graph, "update_graph")
    @graph.create()
    expect(update_spy).toHaveBeenCalledWith(true)
    
  it "should fetch new data when updating", ->
    ajax_spies = spyOn(@graph, "multiple_get")
    @graph.addSerie("path/to/file.rrd", "my_ds", "legend_text", 0, null)
    @graph.update_graph(true)
    expect(ajax_spies)
    
    expect(ajax_spies.mostRecentCall.args.length).toEqual(2)
    expect(ajax_spies.mostRecentCall.args[0][0]).toEqual([jasmine.any(String), jasmine.any(Object)])
    # expect(ajax_spies.argsForCall[0][0][0]).toMatch("^\/rrd\/$")
  
  it "should be able to fetch new data", ->
    ajax_request = spyOn($, "getJSON")
    
    cb = jasmine.createSpy()
    
    s = new Object
    s.set_data = jasmine.createSpy()
    s.get_definition = jasmine.createSpy().andReturn("none")
    # serie_set_data = spyOn(s, "set_data")
    
    @graph.multiple_get([["/url1", s]], cb)
    
    expect(ajax_request).toHaveBeenCalledWith("/url1", jasmine.any(Function))
    ajax_request.mostRecentCall.args[1]([[0, 1], [1, 42]])
    expect(s.set_data).toHaveBeenCalledWith([[0, 1], [1, 42]])
    
    expect(cb).toHaveBeenCalledWith(["none"])
  
  # it "should be able to play a Song", ->
  #   @player.play(@song)
  #   expect(@player.currentlyPlayingSong).toEqual(@song)
  # 
  #   # demonstrates use of custom matcher
  #   expect(@player).toBePlaying(@song)
