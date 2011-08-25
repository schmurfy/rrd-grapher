
require 'bindata'

require File.expand_path('../../structures', __FILE__)

module RRDNotifier
  module BindataParser
  
    # part type
    HOST            = 0x0000
    TIME            = 0x0001
    PLUGIN          = 0x0002
    PLUGIN_INSTANCE = 0x0003
    TYPE            = 0x0004
    TYPE_INSTANCE   = 0x0005
    VALUES          = 0x0006
    INTERVAL        = 0x0007
    MESSAGE         = 0x0100
    SEVERITY        = 0x0101
  
    PART_TYPE_AS_STRING = {
        'host'              => HOST,
        'time'              => TIME,
        'plugin'            => PLUGIN,
        'plugin_instance'   => PLUGIN_INSTANCE,
        'type'              => TYPE,
        'type_instance'     => TYPE_INSTANCE,
        'values'            => VALUES,
        'interval'          => INTERVAL,
        'message'           => MESSAGE,
        'severity'          => SEVERITY
      }.freeze
  
    class ValuePartData < BinData::Record
      COUNTER   = 0
      GAUGE     = 1
      DERIVE    = 2
      ABSOLUTE  = 3
    
      attr_accessor :types
        
      endian :big

      choice :val, :selection => proc{ types[index] }, :choices => {
          COUNTER   => :uint64,
          GAUGE     => :double_le,
          DERIVE    => :int64,
          ABSOLUTE  => :uint64
        }
    
    end
  
    class ValuePart < BinData::Record
      endian :big
  
      int16 :values_count
      array :types, :type => :uint8, :initial_length => proc{ values_count }
      array :vals, :type => [:value_part_data, {:types => :types}], :initial_length => proc{ values_count }
    
    end
  
  
  
    class Part < BinData::Record
      endian  :big
        
      uint16  :part_type
      uint16  :part_length
      
      STR_FIELDS = [HOST, PLUGIN, PLUGIN_INSTANCE, TYPE, TYPE_INSTANCE, MESSAGE]
      INT_FIELDS = [TIME, INTERVAL, SEVERITY]
      
      int64       :integer_value, :onlyif => proc{ INT_FIELDS.include?(part_type) }
      string      :string_value,  :onlyif => proc{ STR_FIELDS.include?(part_type) }, :length => proc{ part_length - 4 }, :trim_padding => true
      value_part  :vals,          :onlyif => proc { part_type == BindataParser::VALUES }
      
      def get_value
        case
        when STR_FIELDS.include?(part_type) then  string_value
        when INT_FIELDS.include?(part_type) then  integer_value
        else
          vals.vals.map(&:val)
        end
      end
      
    end
  
    class Packet < BinData::Record
      array :parts, :type => :part, :read_until => :complete
    
      def method_missing(m, *args)
        type = PART_TYPE_AS_STRING[m.to_s]
        if type
          p = parts.detect{|p| p.part_type == type }
          p.get_value if p
        end
      end
      
      def has_part?(type)
        parts.detect{|p| p.part_type == type }
      end
      
      def complete
        eof ||
        has_part?(VALUES) ||
        has_part?(MESSAGE)
      end
    end
    
    class Reader < BinData::Record
      array :packets, :type => :packet, :read_until => :eof
    end
    
    COMPRESSED_FIELDS = [
        :host,
        :time,
        :interval
      ].freeze
  
    def self.parse(data)
      ret = []
      reader = Reader.new
      packets = reader.read(data).packets
      last_packet = {}
      
      if packets.size >= 1
        
        packets.each_with_index do |packet, i|
          
          p = RRDNotifier::Packet.new(last_packet)
          p.merge_data_from(packet)
          
          last_packet = p if p.data?
          
          ret << p
        end
        
      end
      
      ret
    end

  end
end
