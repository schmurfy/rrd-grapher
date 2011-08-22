require 'rubygems'
require 'bundler/setup'
require 'rrd-grapher/notifier'

puts "Notifier started."

pool = FiberPool.new(10)

EM::run do
  
  pool.spawn do
    opts = {
      :fiber_pool => pool
    }
  
    RRDNotifier::Server.start(opts) do |s|
      s.register_alarm("*", "ping", "ping_droprate", :max => 5)
      s.register_alarm("*", "uptime", "uptime", :monitor_presence => 2*60)
    
      s.register_alarm("*", "load", "load", :max => 0.01, :index => 1)
      s.register_alarm("*", "memory/*", "memory/active", :monitor_presence => 1)
    end
  end
  
end
