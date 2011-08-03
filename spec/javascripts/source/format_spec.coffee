
describe "Format", ->
  beforeEach ->
    @f = Format
  
  it "can format speed", ->
    expect( @f.speed(2048) ).toEqual("2.00&nbsp;KB/s")
    expect( @f.speed(2097152) ).toEqual("2.00&nbsp;MB/s")
  
  it "can format size", ->
    expect( @f.size(2048) ).toEqual("2.00&nbsp;KB")
    expect( @f.size(2097152) ).toEqual("2.00&nbsp;MB")
  
  it "can format time duration", ->
    expect( @f.delay(100) ).toEqual("100&nbsp;ms")
    expect( @f.delay(1000 * 2) ).toEqual("2.00&nbsp;s")
    expect( @f.delay(1000 * 60 * 2) ).toEqual("2.00&nbsp;m")
    expect( @f.delay(1000 * 60 * 60 * 2) ).toEqual("2.00&nbsp;h")