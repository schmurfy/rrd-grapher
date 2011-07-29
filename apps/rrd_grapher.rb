require 'rest-client'
require 'sinatra/base'
require 'sinatra/content_for'
require 'coffe-script'

class RRDGrapher < Sinatra::Base
  helpers Sinatra::ContentFor
  
  __DIR__ = File.join( File.dirname(__FILE__), '..')
  
  # set :markdown, :layout_engine => :haml, :layout => :post
  set :public, __DIR__ + '/public'
  set :views,  __DIR__ + '/views'
  
  get '/available_rrds' do
    haml :available_rrds
  end
  
  get '/graph' do
    haml :graph
  end
  
  
  get '/collectd' do
    haml :collectd
  end
  
  # css
  
  def self.dynamic_css(path)
    get "/stylesheets/#{path}.css" do
      content_type :css
      scss "stylesheets/#{path}".to_sym
    end
  end
  
  dynamic_css('app')
  dynamic_css('available_rrds')
  dynamic_css('graph')
  
  
  # coffee-script js
end