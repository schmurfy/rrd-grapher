require 'rubygems'
require 'bundler/setup'
require 'rrd-grapher/notifier'

puts "Notifier started."

EM::run do
  RRDNotifier::Server.start do |s|
    s.register_alarm("*", "ping", "ping_droprate", :max => 5)
    s.register_alarm("*", "uptime", "uptime", :monitor_presence => 2*60)
    
    s.register_alarm("*", "load", "load", :max => 1, :index => 1)
    s.register_alarm("*", "memory/*", "memory/active", :monitor_presence => 1)
  end
  
end
