# A sample Guardfile
# More info at https://github.com/guard/guard#readme

require 'sprockets'

guard 'coffeescript',
  :input => 'lib/rrd-grapher/assets/javascripts',
  :output => 'lib/rrd-grapher/public/javascripts/generated'

guard 'coffeescript',
  :input => 'spec/javascripts/source',
  :output => 'spec/javascripts'

guard 'sprockets', :destination => "lib/rrd-grapher/public/javascripts" do
  watch (%r{lib/rrd-grapher/assets/javascripts/app.js})
  watch (%r{lib/rrd-grapher/assets/javascripts/app-dev.js})
end


guard 'livereload', :apply_js_live => false do
  watch(%r{^spec/javascripts/.+\.js$})
  watch(%r{^lib/rrd-grapher/public/javascripts/.+\.js$})
  watch(%r{^lib/rrd-grapher/views/stylesheets/.+\.scss$})
end

