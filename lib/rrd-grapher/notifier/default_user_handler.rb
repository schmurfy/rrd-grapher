
module RRDNotifier
  module DefaultNotificationHandler
    def self.dispatch_notification(notification)
      puts "[#{ev.time.strftime('%H:%m:%S')} - #{ev.host}] #{ev.severity} "
      puts %{
        Host: {ev.host}
        Plugin: #{ev.plugin}
        Type: #{ev.type}
        TypeInstance: #{ev.type_instance}
        Severity: #{ev.severity}
        Current Value: #{ev.value}
        Warning thresholds: #{ev.warn_min} - #{ev.warn_max}
        Failure thresholds: #{ev.failure_min} - #{ev.failure_max}
      }
    end
    
    ##
    # A new alarm was triggered
    # 
    # @param [Alarm] alarm the alarm
    # 
    def self.alarm_started(alarm)
      puts "an alarm was started: #{alarm.inspect}"
    end
    
    ##
    # An alarm was stopped
    # 
    # @param [Alarm] alarm the alarm
    #
    def self.alarm_stopped(alarm)
      puts "an alarm was stopped: #{alarm.inspect}"
    end
  end
end
