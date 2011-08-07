
require 'sinatra/base'

module RRDGrapher
  class ResourcesServer < Sinatra::Base
    set :root, File.dirname(__FILE__)
    
    get "/stylesheets/app.css" do
      content_type :css
      scss :"stylesheets/app"
    end
    
  end
end
