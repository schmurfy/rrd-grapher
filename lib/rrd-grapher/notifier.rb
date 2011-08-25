
require 'eventmachine'

require File.expand_path('../notifier/parsers/ruby_parser', __FILE__)
require File.expand_path('../notifier/parsers/bindata_parser', __FILE__)
require File.expand_path('../notifier/alarm_manager', __FILE__)

module RRDNotifier
  
  class Server < EM::Connection
    
    def initialize(alarm_manager, on_init_block = nil)
      @alarm_manager = alarm_manager
      @on_init_block = on_init_block
    end
    
    ##
    # Start the notifier handler, it will open an UDP socket
    # to which collectd should send its data using the network module.
    # 
    # @param [Hash] opts options hash
    # @option opts [String] :host UDP address to bind on (default: 127.0.0.1)
    # @option opts [Integer] :port UDP port to bind on
    # @option opts [Object] :notification_handler This object 
    # 
    def self.start(opts = {}, &block)
      host = opts.delete(:host) || '127.0.0.1'
      port = opts.delete(:port) || 10000
      
      alarm_manager = AlarmManager.new(opts)
      
      unless opts.empty?
        raise "Unknown arguments: #{opts}"
    
      end
      EM::open_datagram_socket(host, port, Server, alarm_manager, block)
    end
    
    
    ##
    # Register a new monitoring alert.
    # @see AlertManager::register_alert
    # 
    def register_alarm(*args)
      @alarm_manager.register_alarm(*args)
    end
    
    
# Eventmachine callbacks
    
    def post_init
      @on_init_block.call(self) if @on_init_block
    end
    
    ##
    # EventMachine callback called when a packet is available
    # 
    # @param [String] data data received
    # 
    def receive_data(data)
      if packets = RubyParser::parse(data)
        packets.each do |p|
          @alarm_manager.packet_received(p)
        end
      end
    end
  end
  
end
