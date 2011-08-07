require 'rest-client'
require 'sinatra/base'
require 'sinatra/content_for'

class TestApp < Sinatra::Base
  helpers Sinatra::ContentFor
  
  set :haml, :format => :html5
  
  # set :markdown, :layout_engine => :haml, :layout => :post
  set :root, File.dirname(__FILE__)
  
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
  
  dynamic_css('available_rrds')
  dynamic_css('graph')
  
end