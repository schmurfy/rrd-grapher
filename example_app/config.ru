require 'bundler/setup'
require 'rrd-grapher'

require File.expand_path('../app', __FILE__)

use RRDGrapher::RRDServer, :root_path => "/usr/local/var/lib/collectd/"
use RRDGrapher::ResourcesServer

run TestApp
