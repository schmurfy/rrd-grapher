
module RRDNotifier
  ##
  # An active alarm.
  # 
  class Alarm
    # the packet which triggered the alarm
    attr_accessor :packet
    
    def initialize(p)
      @packet = p
    end
    
    
    def plugin_display
      if packet.plugin_instance
        "#{packet.plugin}/#{packet.plugin_instance}"
      else
        packet.plugin
      end
    end
    
    def type_display
      if packet.type_instance
        "#{packet.type}/#{packet.type_instance}"
      else
        packet.type
      end
    end
  end
  
  class AlarmTooHigh < Alarm
    def reason; :too_high; end
    
    attr_accessor :threshold
    
    def initialize(p, threshold)
      super(p)
      @threshold = threshold
    end
    
    def is_same?(threshold)
      @threshold == threshold
    end
  end
  
  class AlarmTooLow < AlarmTooHigh
    def reason; :too_low; end
  end
  
  class AlarmMissingData < Alarm
    def reason; :missing_data; end
    
    ##
    # Time allowed between updates.
    attr_accessor :allowed_interval
    
    ##
    # When was this measure last updated ?
    attr_accessor :last_update
    
    def initialize(p, allowed_interval ,last_update)
      super(p)
      @allowed_interval = allowed_interval
      @last_update = last_update
    end
    
    def is_same?(allowed_interval ,last_update)
      (@allowed_interval == allowed_interval) &&
      (@last_update == last_update)
    end
  end
  
  class AlarmClockDrift < Alarm
    def reason; :clock_drift; end
    
    # difference in seconds between our clock
    # and the one of the host
    attr_accessor :allowed_drift
    
    def initialize(p, allowed_drift)
      super(p)
      @allowed_drift = allowed_drift
    end
    
    def is_same?(drift)
      @allowed_drift == drift
    end
  end
end
