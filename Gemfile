source :rubygems

gem 'sinatra'
gem 'sinatra-content-for'
gem 'thin'
gem 'haml'
gem 'sass'
gem 'coffee-script'

gem 'unicorn'

group(:rrd) do
  gem 'rrd-ffi', :git => 'git://github.com/schmurfy/rrd-ffi.git'
  gem 'i18n'
end


group(:dev) do
  gem 'therubyracer'
  gem 'guard-coffeescript'
  gem 'guard-livereload'
end


group(:grapher) do
  gem 'rest-client'
end

group(:test) do
  gem 'bacon'
  gem 'mocha'
  gem 'jasmine'
  gem 'factory_girl'
  gem 'simplecov'
end
