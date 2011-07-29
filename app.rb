require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra'
require 'json'
require 'haml'
require 'sass'

require File.expand_path('../apps/rrd_server', __FILE__)
require File.expand_path('../apps/rrd_grapher', __FILE__)







