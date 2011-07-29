require 'bundler/setup'
require File.expand_path('../../lib/rrd', __FILE__)

if ARGV.size != 1
  puts "Usage: #{File.basename($0)} <rrd_file>"
  puts "This tool will feed the rrd wil generated data"
  exit(1)
end

rrd_path = ARGV[0]

rrd = RRDReader::File.new(rrd_path)

# raise "Too many ds !" if rrd.ds.size != 1

trap('INT'){ exit(0) }

# find interval
interval = rrd.step
values = []
rrd_count = rrd.ds.size

0.upto(rrd_count - 1) do |n|
  values[n] = rand(5000)
end


puts "Detected #{rrd_count} Data sources."

while true
  time = Time.new
  cmd_line = [time.to_i]
  
  0.upto(rrd_count - 1) do |n|
    # new_data = [value + 1].map {|item| item.nil? ? "U" : item}
    # new_data = [time.to_i] + new_data
    cmd_line << (values[n] + 1) || "U"
    puts "[#{n}] Written: #{values[n] + 1} at #{time.to_i}"
    values[n] += rand(200) - 100
    values[n] = [0, [values[n],5000].min].max
  end
  
  RRD::Wrapper.update(rrd_path, cmd_line.join(":"))
  
  sleep(interval)
end
