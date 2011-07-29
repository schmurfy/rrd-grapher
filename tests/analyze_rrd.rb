require 'rubygems'
require 'rrd'
require 'pp'
require 'chronic_duration'



if ARGV.size != 1
  puts "Usage: #{File.basename($0)} <rrd_file>"
  puts "This tool will extract data from the RRD and display it"
  exit(1)
end


# FILE="/Users/schmurfy/Dev/personal/rrd-faces/preprod_data/cpu-idle.rrd"
# FILE="/Users/schmurfy/Dev/personal/rrd-grapher/specs/data/test.rrd"
# FILE="/Users/schmurfy/Dev/personal/rrd-grapher/specs/myrouter.rrd"
# FILE="/Users/schmurfy/Dev/personal/rrd-grapher/specs/data/subdata.rrd"
FILE = ARGV[0]

rrd = RRD::Base.new(FILE)
raw_infos = rrd.info
infos = {
  :filename => raw_infos.delete("filename"),
  :rrd_version => raw_infos.delete("rrd_version"),
  # data will be added in this rrd every <step> seconds
  :step => raw_infos.delete("step"),
  :last_update => raw_infos.delete("last_update"),
  :header_size => raw_infos.delete("header_size"),
  :ds => {},
  :rra => []
}

# pp raw_infos

raw_infos.each do |key, val|
  case key
  when %r{^ds\[([a-zA-Z_]+)\]\.([a-zA-Z_]+)}
    infos[:ds][$1] ||= {}
    infos[:ds][$1][$2] = val
  
  when %r{^rra\[([0-9]+)\]\.([a-zA-Z_]+)}
    infos[:rra][$1.to_i] ||= {}
    infos[:rra][$1.to_i][$2] = val
  end
end

# pp infos

# base interval
step = infos[:step]
puts ""
infos[:rra].each do |data|
  print "#{data['cf'].rjust(10)}: "
  
  time_point = ChronicDuration.output(data['pdp_per_row'] * step)
  print "a point every #{time_point} "
  
  time_store = ChronicDuration.output(data['rows'] * (data['pdp_per_row'] * step))
  puts "stored for #{time_store}"
end

