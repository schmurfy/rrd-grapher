require 'rest-client'
require 'sinatra/content_for'

class RRDGrapher < Sinatra::Base
  helpers Sinatra::ContentFor
  
  __DIR__ = File.dirname(__FILE__)
  
  # set :markdown, :layout_engine => :haml, :layout => :post
  set :public, __DIR__ + '/public'
  set :views,  __DIR__ + '/views'
  
  get '/available_rrds' do
    haml :available_rrds
  end
  
  
  # css
  get '/stylesheets/app.css' do
    content_type :css
    scss :'stylesheets/app'
  end
  
  get '/stylesheets/available_rrds.css' do
    content_type :css
    scss :'stylesheets/available_rrds'
  end
  
end