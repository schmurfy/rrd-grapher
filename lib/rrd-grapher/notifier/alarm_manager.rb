
require 'fiber_pool'

require File.expand_path('../structures', __FILE__)
require File.expand_path('../alarms', __FILE__)
require File.expand_path('../alarm_trigger', __FILE__)
require File.expand_path('../default_user_handler', __FILE__)

module RRDNotifier
    
  ##
  # Trigger/Stop the alarms based on user configuration
  # 
  class AlarmManager
    
    attr_reader :fiber_pool
    
    ##
    # Create a new AlertManager object
    # 
    # @param [Hash] opts options
    # @option opts [Module,Object] notification_manager The object
    #   used when a new notification is triggered/stopped
    # @option opts [FiberPool] fiber_pool Fiber pool to use.
    # 
    def initialize(opts = {})
      @notification_handler = opts.delete(:notification_handler) || DefaultNotificationHandler
      
      unless valid_notification_handler?(@notification_handler)
        raise "notification_handler #{@notification_handler} invalid, some callbacks are missing !"
      end
      
      @fiber_pool = opts.delete(:fiber_pool) || FiberPool.new(10)
      @triggers = []
      @active_alarms = {}
      @last_updates = {}
    end
    
    ##
    # Check that the object respond to the required
    # methods.
    # 
    # @param [Object] obj the handler
    # 
    def valid_notification_handler?(obj)
      obj.respond_to?(:dispatch_notification) &&
      obj.respond_to?(:alarm_started) &&
      obj.respond_to?(:alarm_stopped)
    end
    
    ##
    # Register a new alarm.
    # @see AlarmTrigger::initialize
    # 
    def register_alarm(*args)
      @triggers << AlarmTrigger.new(self, *args)
    end
    
    ##
    # Called by the Notifier when an event is successfully extracted
    # from a collectd packet.
    # 
    # @param [Packet] p packet received
    # 
    def packet_received(p)
      @fiber_pool.spawn do
        if p.data?
          trigger_notifications(p)
          @last_updates[p.measure_id] = Time.now
        else
          @notification_handler.dispatch_notification(p)
        end
      end
    end
    
    
    ##
    # Called all the triggers matching this packet
    # to see if one or more wants to start/stop alarms.
    # 
    # @param [Packet] p the packet
    # 
    def trigger_notifications(p)
      @triggers.each{|t| t.check_alarms(p) }
    end
    
    
  # Alarm api, used by the triggers
    
    ##
    # Raise an alarm.
    # 
    # @param [String] measure_id counter ID
    # @param [Alarm] alarm An alarm object
    # 
    def raise_alarm(measure_id, alarm)
      @notification_handler.alarm_started(alarm)
      (@active_alarms[measure_id] ||= []) << alarm
    end
    
    ##
    # Used by triggers to query the time of the last update for
    # this measure.
    # 
    # @param [String] measure_id ID Representing this particular
    #   counter
    # 
    def last_update_for(measure_id)
      @last_updates[measure_id]
    end
    
    def active_alarms_for(measure_id)
      @active_alarms[measure_id] ||= []
    end
    
    ##
    # Stop an alarm.
    # 
    # @param [String] measure_id counter ID
    # @param [Alarm] alarm An alarm object
    # 
    def stop_specific_alarm(measure_id, alarm)
      active_alarms_for(measure_id).delete(alarm)
      @notification_handler.alarm_stopped(alarm)
    end
    
    ##
    # Stop an alarm matching specified params.
    # 
    # @param [String] measure_id counter ID
    # @param [Class] alarm_class The alarm class
    # @param [Array] args these will be given to
    #   Alarm::is_same? so the alarm can tell us if
    #   it matchs.
    # 
    # @note This method is just a wrapper around
    #   active_alarm? and stop_specific_alarm.
    # 
    def stop_alarm(measure_id, alarm_class, *args)
      # check if we have an active alarm
      alarm = active_alarm?(measure_id, alarm_class, *args)
      if alarm
        stop_specific_alarm(measure_id, alarm)
      end
    end
    
    
    ##
    # Return the active alarm matching given
    # parameters.
    # 
    # @param [String] measure_id counter ID
    # @param [Class] alarm_class The alarm class
    # @param [Array] args these will be given to
    #   Alarm::is_same? so the alarm can tell us if
    #   it matchs.
    # 
    def active_alarm?(measure_id, alarm_class, *args)      
      # fetch active alarms
      active_alarms = active_alarms_for(measure_id)
      
      # check if we have an active alarm
      active_alarms.detect do |al|
        al.is_a?(alarm_class) && al.is_same?(*args)
      end
    end
    
  end
  
end
