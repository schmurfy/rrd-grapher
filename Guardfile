# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'coffeescript',
  :input => 'assets/javascripts',
  :output => 'public/javascripts/generated'

guard 'coffeescript',
  :input => 'spec/javascripts/source',
  :output => 'spec/javascripts'



guard 'livereload', :apply_js_live => false do
  watch(%r{^spec/javascripts/.+\.js$})
  watch(%r{^public/javascripts/.+\.js$})
  watch(%r{^views/stylesheets/.+\.scss$})
  watch(%r{^views/.+\.haml$})
end

