require File.expand_path('../../common', __FILE__)
require File.expand_path('../../../lib/rrd-grapher/notifier/data_struct', __FILE__)

describe 'DataStruct' do
  before do
    @s1 = Class.new(DataStruct) do
      properties :one, :two
    end
    
    @s2 = Class.new(DataStruct) do
      properties :name, :host
    end
  end
  
  should 'have disctinct attributes set for each child class' do
    @s1.attributes.should == [:one, :two]
    @s2.attributes.should == [:name, :host]
  end
  
  it "can merge data from multiple Hash sources" do
    obj = @s1.new(:one => 12)
    obj.merge_data_from(:two => 34, :one => nil)
    
    obj.one.should == 12
    obj.two.should == 34
  end
  
  it "can merge data from multiple Object sources" do
    dummy_class = Struct.new(:one, :two)
    
    d1 = dummy_class.new(23)
    d2 = dummy_class.new(nil, 56)
    
    obj = @s1.new(d1)
    obj.merge_data_from(d2)
    
    obj.one.should == 23
    obj.two.should == 56
  end
  
  it "can merge data selectively from multiple Object sources" do
    dummy_class = Struct.new(:one, :two)
    
    d1 = dummy_class.new(23)
    d2 = dummy_class.new(67, 56)
    
    obj = @s1.new(d1)
    obj.merge_data_from(d2, [:two])
    
    obj.one.should == 23
    obj.two.should == 56
  end
  
end

