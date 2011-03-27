
require 'rrd'
require File.expand_path('../../lib/rrd', __FILE__)

# env[:rrd_base_path]

class RRDServer < Sinatra::Base
  before do
    content_type :json
  end
  
  get '/rrd' do
    ret = []
    
    Dir.chdir(root_path) do
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
  get '/rrd/:path/values/:from/:to' do
    rrd = load_rrd( "#{params[:path]}.rrd" )
    ret = rrd.get_values("AVERAGE", params[:from].to_i, params[:to].to_i, {
      :rra => params[:rra].to_i
    })
    ret.to_json
  end
  
private
  def load_rrd(short_path)
    RRDReader::File.new(short_path, root_path)
  end
  
  def root_path
    env[:rrd_base_path]
  end
end

