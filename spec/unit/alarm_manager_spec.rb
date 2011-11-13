
require 'eventmachine'

require File.expand_path('../../common', __FILE__)
require File.expand_path('../../../lib/rrd-grapher/notifier/alarm_manager', __FILE__)


describe 'AlarmManager' do
  before do
    @manager = RRDNotifier::AlarmManager.new
  end
  
  should 'create the manager' do
    @manager.should.not == nil
  end
  
  describe 'with a user notification handler' do
    before do
      @handler_class = Class.new do
        def dispatch_notification(notification); end
        def alarm_started(alarm); end
        def alarm_stopped(alarm); end
      end
      
      @handler = @handler_class.new
      
      @manager = RRDNotifier::AlarmManager.new(:notification_handler => @handler)
    end
    
    should 'dispatch notification as is' do
      notif = Factory(:notification)
      @handler.expects(:dispatch_notification).with(notif)
      @manager.packet_received(notif)
    end
    
    should 'notify the user handler when an alarm is raised' do
      packet = Factory(:data_point)
      alarm = RRDNotifier::AlarmTooLow.new(packet, 10)
      
      @handler.expects(:alarm_started).with(alarm)
      @manager.raise_alarm(packet.measure_id, alarm)
    end
  
    should 'notify the user handler when an alarm is stopped' do
      p = Factory(:data_point)
      alarm = RRDNotifier::AlarmTooLow.new(p, 10)
      
      @handler.expects(:alarm_stopped).with(alarm)
      @manager.stop_specific_alarm(p.measure_id, alarm)
    end
  end
  
  describe 'a trigger on low value' do
    before do
      @manager.register_alarm('*', "memory/*", "memory/active", :min => 10)
    end
    
    should 'raise an alarm for a value below the threshold' do
      p = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
    
      @manager.expects(:raise_alarm).with(p.measure_id, kind_of(RRDNotifier::AlarmTooLow) )
    
      @manager.packet_received(p)
    end
    
    should 'not raise an alarm for a value above the threshold' do
      p = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
    
      @manager.expects(:raise_alarm).never
    
      @manager.packet_received(p)
    end
    
    should 'not reraise another alarm if the value stays below the threshold' do
      p_alarm = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      p_alarm2 = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [5])
      
      @manager.expects(:active_alarms_for).with(p_alarm.measure_id).returns( [RRDNotifier::AlarmTooLow.new(p_alarm, 10)] )
      @manager.expects(:raise_alarm).never
      
      @manager.packet_received(p_alarm2)
    end
    
    should 'stop the alarm when the value comes back above the threshold' do
      p_alarm = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      p_normal = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      
      @manager.expects(:active_alarms_for).with(p_alarm.measure_id).returns( [RRDNotifier::AlarmTooLow.new(p_alarm, 10)] )
      
      @manager.expects(:raise_alarm).never
      @manager.expects(:stop_specific_alarm).with( p_normal.measure_id, kind_of(RRDNotifier::AlarmTooLow) )
    
      @manager.packet_received(p_normal)
    end
    
  end
  
  describe 'a trigger on high value' do
    before do
      @manager.register_alarm('*', "memory/*", "memory/active", :max => 10)
    end
    
    should 'raise an alarm for a value above the threshold' do
      p = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
    
      @manager.expects(:raise_alarm).with(p.measure_id,  kind_of(RRDNotifier::AlarmTooHigh) )
    
      @manager.packet_received(p)
    end
    
    should 'not raise an alarm for a value below the threshold' do
      p = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
    
      @manager.expects(:raise_alarm).never
    
      @manager.packet_received(p)
    end
    
    should 'not reraise another alarm if the value stays above the threshold' do
      p_alarm = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      p_alarm2 = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      
      @manager.expects(:active_alarms_for).with(p_alarm.measure_id).returns( [RRDNotifier::AlarmTooLow.new(p_alarm, 10)] )
      @manager.expects(:raise_alarm).never
      
      @manager.packet_received(p_alarm2)
    end
    
    should 'stop the alarm when the value comes back below the threshold' do
      p_alarm = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      p_normal = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      
      @manager.expects(:active_alarms_for).with(p_alarm.measure_id).returns( [RRDNotifier::AlarmTooHigh.new(p_alarm, 10)] )
      
      @manager.expects(:raise_alarm).never
      @manager.expects(:stop_specific_alarm).with( p_normal.measure_id, kind_of(RRDNotifier::AlarmTooHigh) )
    
      @manager.packet_received(p_normal)
    end
  end
  
  describe 'a trigger on clock drift' do
    before do
      @manager.stubs(:send_gauge)
      @manager.register_alarm('*', "memory/*", "memory/active",
          :monitor_drift => 30 # allow 30s of drift
        )
    end
    
    should 'raise an alarm if time difference is higher than threshold' do
      p = Factory(:data_point, :time => Time.now - 60, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      @manager.expects(:raise_alarm).with(p.measure_id,  kind_of(RRDNotifier::AlarmClockDrift) )
    
      @manager.packet_received(p)
      
      p = Factory(:data_point, :time => Time.now + 60, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      @manager.expects(:raise_alarm).with(p.measure_id,  kind_of(RRDNotifier::AlarmClockDrift) )
    
      @manager.packet_received(p)
    end
    
    should 'not raise an alarm if time difference is below the threshold' do
      p = Factory(:data_point, :time => Time.now - 20, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      @manager.expects(:raise_alarm).never
    
      @manager.packet_received(p)
      
      p = Factory(:data_point, :time => Time.now + 20, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      @manager.expects(:raise_alarm).never
    
      @manager.packet_received(p)
    end
    
    should 'not reraise another alarm if time difference stays above the threshold' do
      p_alarm = Factory(:data_point, :time => Time.now - 60, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      p_alarm2 = Factory(:data_point, :time => Time.now - 50, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      
      @manager.expects(:active_alarms_for).with(p_alarm.measure_id).returns( [RRDNotifier::AlarmClockDrift.new(p_alarm, 30)] )
      @manager.expects(:raise_alarm).never
      
      @manager.packet_received(p_alarm2)
    end
    
    should 'stop the alarm if time difference moves below the threshold' do
      p_alarm = Factory(:data_point, :time => Time.now - 60, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      p_normal = Factory(:data_point, :time => Time.now - 10, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [81])
      
      @manager.expects(:active_alarms_for).with(p_alarm.measure_id).returns( [RRDNotifier::AlarmClockDrift.new(p_alarm, 30)] )
      
      @manager.expects(:raise_alarm).never
      @manager.expects(:stop_specific_alarm).with( p_normal.measure_id, kind_of(RRDNotifier::AlarmClockDrift) )
    
      @manager.packet_received(p_normal)
    end
    
  end
  
  describe 'a trigger on presence' do
    before do
      @interval = 0.5 # seconds
      @manager.register_alarm('*', "memory/*", "memory/active",
          :monitor_presence => @interval
        )
    end
    
    should 'raise an alarm if value is missing for more than the threshold' do
      p = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      
      # force the timer to be called
      EM::expects(:add_timer).with(@interval).yields()
      
      @manager.expects(:raise_alarm).with(p.measure_id, kind_of(RRDNotifier::AlarmMissingData) )
      @manager.packet_received(p)
    end
    
    should 'not raise an alarm is value missing for less than the threshold' do
      p = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      
      # catch the timer creation but do not execute its callback
      EM::expects(:add_timer).with(@interval)
      
      @manager.expects(:raise_alarm).never
      @manager.packet_received(p)
    end
    
    should 'stop the alarm when a value is received' do
      p_alarm = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      p_normal = Factory(:data_point, :plugin => "memory", :type => "memory", :type_instance => "active", :values => [8])
      
      alarm_time = Time.now - 60
      @manager.stubs(:last_update_for).with(p_alarm.measure_id).returns(alarm_time)
      
      
      # catch the timer creation and execute the calback to raise an alarm
      timer_id = stub()
      EM::expects(:add_timer).with(@interval).yields.returns(timer_id).once
      @manager.expects(:raise_alarm).with(p_alarm.measure_id, kind_of(RRDNotifier::AlarmMissingData) )
      @manager.packet_received(p_alarm)
      
      
      EM::expects(:cancel_timer).with(timer_id)
      EM::expects(:add_timer).with(@interval)
      @manager.expects(:active_alarms_for).with(p_alarm.measure_id).returns( [RRDNotifier::AlarmMissingData.new(p_alarm, @interval, alarm_time)] )
      @manager.expects(:stop_specific_alarm).with( p_normal.measure_id, kind_of(RRDNotifier::AlarmMissingData) )
      @manager.expects(:raise_alarm).never
          
      @manager.packet_received(p_normal)
    end
    
  end
  
end
