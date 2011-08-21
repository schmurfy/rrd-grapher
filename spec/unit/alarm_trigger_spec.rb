require File.expand_path('../../common', __FILE__)
require File.expand_path('../../../lib/rrd-grapher/notifier/alarm_trigger', __FILE__)

describe 'AlarmTrigger' do
  it 'can can parse initialize parameters' do
    RRDNotifier::AlarmTrigger.load_param("*").should == nil
    RRDNotifier::AlarmTrigger.load_param("memory").should == "memory"
    RRDNotifier::AlarmTrigger.load_param("memory/*").should == ["memory", nil]
    RRDNotifier::AlarmTrigger.load_param("*/*").should == [nil, nil]
    RRDNotifier::AlarmTrigger.load_param("*/memory").should == [nil, "memory"]
  end
  
  it 'can handle packets with multiple counters' do
    manager = stub('manager', :active_alarm? => nil)
    trigger = RRDNotifier::AlarmTrigger.new(manager, "*", "*/*", "*/*", :max => 10, :index => 1)
    
    # we are not testing matching code, bypass
    trigger.expects(:match?).returns(true)
    p = Factory(:data_point, :values => [1, 45, 5])
    
    manager.expects(:raise_alarm).with(p.measure_id, kind_of(RRDNotifier::Alarm))
    trigger.check_alarms(p)
  end
end


