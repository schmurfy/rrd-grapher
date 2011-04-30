require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra'
require 'json'
require 'sass'

# use Rack::Lint

require File.expand_path('../apps/rrd_server', __FILE__)
require File.expand_path('../apps/rrd_grapher', __FILE__)

use Rack::Config do |env|
  env[:rrd_base_path] = File.expand_path('../tests', __FILE__)
  # env[:rrd_base_path] = "/Users/schmurfy/Dev/personal/rrd-faces/preprod_data"
end

use RRDServer
use RRDGrapher

# use Rack::Cascade.new [RRDServer, RRDGrapher]





