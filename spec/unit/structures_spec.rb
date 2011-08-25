require File.expand_path('../../common', __FILE__)
require File.expand_path('../../../lib/rrd-grapher/notifier/structures', __FILE__)

describe 'Packet' do
  before do
    @point = Factory(:data_point)
  end

  should 'return formatted plugin' do
    @point.plugin = "plugin"
    @point.plugin_instance = nil

    @point.plugin_display.should == "plugin"

    @point.plugin_instance = "instance"
    @point.plugin_display.should == "plugin/instance"
  end

  should 'return formatted type' do
    @point.type = "type"
    @point.type_instance = nil

    @point.type_display.should == "type"

    @point.type_instance = "instance"
    @point.type_display.should == "type/instance"
  end
end
