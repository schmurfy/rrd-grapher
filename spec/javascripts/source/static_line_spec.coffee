
describe "StaticLine", ->
  beforeEach ->
    @line = new StaticLine(13, "red")
  
  
  it "should return its definition", ->
    expected_def = {
        data: [[jasmine.any(Number), 13], [jasmine.any(Number), 13]],
        legend: "",
        color: 'red'
      }
    expect(@line.get_definition(0, 1)).toEqual(expected_def)
