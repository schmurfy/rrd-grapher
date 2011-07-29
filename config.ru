require File.expand_path('../app', __FILE__)

use Rack::Config do |env|
  # env[:rrd_base_path] = File.expand_path('../tests', __FILE__)
  env[:rrd_base_path] = "/usr/local/var/lib/collectd"
end

# use Rack::Lint

use RRDServer
run RRDGrapher

# use Rack::Cascade.new [RRDServer, RRDGrapher]
# run Sinatra::Application

