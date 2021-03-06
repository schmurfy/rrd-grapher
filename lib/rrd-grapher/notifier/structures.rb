
require File.expand_path('../data_struct', __FILE__)

module RRDNotifier
  # from collectd source code
  # plugin.h
  # 
  ### notification:
  # int severity;
  # cdtime_t time;
  # char message[NOTIF_MAX_MSG_LEN];
  # char host[DATA_MAX_NAME_LEN];
  # char plugin[DATA_MAX_NAME_LEN];
  # char plugin_instance[DATA_MAX_NAME_LEN];
  # char type[DATA_MAX_NAME_LEN];
  # char type_instance[DATA_MAX_NAME_LEN];
  # 
  ### data
  # value_t *values;
  # int values_len;
  # cdtime_t time;
  # cdtime_t interval;
  # char host[DATA_MAX_NAME_LEN];
  # char plugin[DATA_MAX_NAME_LEN];
  # char plugin_instance[DATA_MAX_NAME_LEN];
  # char type[DATA_MAX_NAME_LEN];
  # char type_instance[DATA_MAX_NAME_LEN];
  # 
  class Packet < DataStruct
      properties :time,
        :host,
        :plugin,
        :plugin_instance,
        :type,
        :type_instance,
        
        # data
        :interval,
        :values,
        
        # notification
        :message,
        :severity
      
      def notification?
        !self.message.nil?
      end
      
      def data?
        self.message.nil?
      end
      
      def value(index = 0)
        values[index]
      end
      
      def plugin_display
        if plugin_instance && !plugin_instance.empty?
          "#{plugin}/#{plugin_instance}"
        else
          plugin
        end
      end

      def type_display
        if type_instance &&  !type_instance.empty?
          "#{type}/#{type_instance}"
        else
          type
        end
      end
      ##
      # return a unique id for the measured data.
      # 
      def measure_id
        "#{host}-#{plugin_display}-#{type_display}"
      end
      
  end
end
