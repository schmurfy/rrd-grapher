
require 'sinatra/base'

require 'rrd'
require File.expand_path('../rrd', __FILE__)

module RRDGrapher
  class RRDServer < Sinatra::Base
    
    def initialize(app, opts = {})
      @app = app
      @root_path = opts.delete(:root_path)
      # use rrdcached ?
      # value must be the path to the unix socket
      @rrdcached = opts.delete(:rrdcached)
      
      unless opts.empty?
        raise "Unknown options: #{opts.inspect}"
      end
    end
    
    set :public, nil
    set :views,  nil
    set :reload_templates, false
    
    before do
      content_type :json
    end
  
    get '/rrd' do
      ret = []
    
      Dir.chdir(@root_path) do
        Dir["**/*.rrd"].each do |rrd_path|
          ret << load_rrd(rrd_path)
        end
      end
    
      ret.to_json(false)
    end
  
  
    get '/rrd/:path/rra' do
      rrd = load_rrd( "#{params[:path]}.rrd" )
      rrd.archives.to_json
    end
  
    get '/rrd/:path/ds' do
      rrd = load_rrd( "#{params[:path]}.rrd" )
      rrd.ds.to_json
    end
  
    # optional parameters:
    # - rra: if present the range will be clipped wihin it
    #
    get %r{/rrd/(.+)/values/([0-9.]+)/([0-9.]+)} do
      args = {}
    
      path, from, to = params[:captures]
    
      args[:rra] = params[:rra].to_i if params[:rra]
      args[:maxrows] = params[:maxrows].to_i if params[:maxrows]
      args[:ds_name] = params[:ds_name] if params[:ds_name]
      args[:rrdcached] = @rrdcached
    
      rrd = load_rrd( "#{path}.rrd" )
      ret = rrd.xport_values("AVERAGE", from.to_i, to.to_i, args)
      
      ret.to_json
    end
  
  private
    def load_rrd(short_path)
      RRDReader::File.new(short_path, @root_path)
    end
    
  end
end
