
require File.expand_path('../structures', __FILE__)
require File.expand_path('../alarms', __FILE__)

module RRDNotifier
  ##
  # Represents the conditions to raise an alarm.
  # 
  class AlarmTrigger
    ##
    # Create a new AlarmTrigger object.
    # 
    # @param [AlertManager] manager The manager
    #   (used to raise/stop alarms and query informations)
    # @param [String, nil] host the hostname (nil: any host)
    # @param [String] plugin plugin name
    #   ex: something (any plugin_instance matched)
    #   ex: something/inst (match both plugin and plugin_instance)
    # @param [String] type type name (see plugin for format)
    # @param [Hash] opts Alarm option
    # @option opts [Number] min minimal allowed value
    # @option opts [Number] max maximum allowed value
    # @option opts [Number] monitor_presence raise an
    #   alarm if data is missing for x seconds
    # @option opts [Boolean] monitor_drift Ensure the clock
    #   of the host is not drifting too far from our clock
    #   (default: false)
    # @option opts [Integer] index for multi-values counters this
    #   parameter allow you to select what you want to monitor
    #   (default: 0)
    # 
    def initialize(manager, host, plugin, type, opts = {})
      @host = self.class.load_param(host)
      @plugin, @plugin_instance = self.class.load_param(plugin)
      @type, @type_instance = self.class.load_param(type)
    
      @manager = manager
      
      @index = opts.delete(:index) || 0
      @min = opts.delete(:min)
      @max = opts.delete(:max)
      @monitor_drift = opts.has_key?(:monitor_drift) ? opts.delete(:monitor_drift) : false
      @monitor_presence = opts.has_key?(:monitor_presence) ? opts.delete(:monitor_presence) : false
    
      raise "Unknown arguments: #{opts.inspect}" unless opts.empty?
    
      @timers_register = {}
    end
  
    ##
    # Split if arg contains a "/" and
    # return nil if a "*" is found.
    # 
    # @param [String] str source string
    # @return [Array] result
    # 
    def self.load_param(str)
      raise "nil is not a valid value" unless str
    
      ret = str.split("/").map! do |s|
        (s == '*') ? nil : s
      end
    
      (ret.size == 1) ? ret[0] : ret
    end
  
    ##
    # Checks if this packet is interesting for the
    # trigger.
    # 
    # @param [DataPoint] p the packet
    # @return [Boolean] true if the packet is interesting
    # 
    def match?(p)
      (@host.nil? || (@host == p.host)) &&
      (@plugin.nil? || (@plugin == p.plugin)) &&
      (@plugin_instance.nil? || (@plugin_instance == p.plugin_instance)) &&
      (@type.nil? || (@type == p.type)) &&
      (@type_instance.nil? || (@type_instance == p.type_instance))
    end
  
    ##
    # Called by the manager when a packet is received.
    # 
    # @param [DataPoint] p the packet
    # 
    def check_alarms(p)
      # if the packet is not intersting for me, stop here
      unless match?(p)
        return
      end
      
      if @index >= p.values.size
        puts "index #{@index} was given but only #{p.values.size} found, check disabled"
        return
      end
      
      value = p.value(@index)
      
      check_alarm_high(p, value)
      check_alarm_low(p, value)
      check_alarm_presence(p, value)
      check_alarm_drift(p, value)
    end
    
    def check_alarm_high(p, value)
      return unless @max
      
      if value > @max
        unless @manager.active_alarm?(p.measure_id, AlarmTooHigh, @max)
          @manager.raise_alarm( p.measure_id, AlarmTooHigh.new(p, @max) )
        end
      else
        @manager.stop_alarm(p.measure_id, AlarmTooHigh, @max)
      end
    end
    
    def check_alarm_low(p, value)
      return unless @min
      
      if value < @min
        unless @manager.active_alarm?(p.measure_id, AlarmTooLow, @min)
          @manager.raise_alarm( p.measure_id, AlarmTooLow.new(p, @min) )
        end
      else
        @manager.stop_alarm(p.measure_id, AlarmTooLow, @min)
      end
    end
    
    
    def check_alarm_drift(p, value)
      return unless @monitor_drift
      now = Time.now
      
      # check the absolute value of the difference between
      # current server time and time included in the collectd
      # packet.
      if (now - p.time).abs > @monitor_drift
        unless @manager.active_alarm?(p.measure_id, AlarmClockDrift, @monitor_drift)
          @manager.raise_alarm( p.measure_id, AlarmClockDrift.new(p, @monitor_drift) )
        end
      else
        @manager.stop_alarm(p.measure_id, AlarmClockDrift, @monitor_drift)
      end
    end
    
    
    def check_alarm_presence(p, value)
      return unless @monitor_presence
      
      # stop any already active alarm
      last_update = @manager.last_update_for(p.measure_id)
      @manager.stop_alarm(p.measure_id, AlarmMissingData, @monitor_presence, last_update)
    
      # reset any active timer
      timer_id = @timers_register[p.measure_id]
      EM::cancel_timer(timer_id) if timer_id
    
      # and create a new one
      @timers_register[p.measure_id] = EM::add_timer(@monitor_presence) do
        presence_timeout(p)
      end
    end
  
    ##
    # Raise a presence alarm.
    # 
    # @param [DataPoint] p the data point
    # 
    def presence_timeout(p)
      @manager.fiber_pool.spawn do
        last_update = @manager.last_update_for(p.measure_id)
        @manager.raise_alarm( p.measure_id, AlarmMissingData.new(p, @monitor_presence, last_update) )
      end
    end
  
  end
end
