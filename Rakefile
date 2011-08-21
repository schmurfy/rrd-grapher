
require 'sprockets'

def pack_js(src_file)
  secretary = ::Sprockets::Secretary.new(
    :asset_root            => "lib",
    :source_files          => ["lib/rrd-grapher/assets/javascripts/#{src_file}"],
    :interpolate_constants => false
  )
  
  concatenation = secretary.concatenation
  concatenation.save_to("lib/rrd-grapher/public/javascripts/#{src_file}")
  secretary.install_assets
end

# compile and pack coffee files
task :build do
  # core
  sh "coffee -c -o lib/rrd-grapher/public/javascripts lib/rrd-grapher/assets/javascripts/"
  
  # example_app
  sh "coffee -c -o example_app/public/javascripts example_app/assets/javascripts/"
  
  # sprockets
  pack_js("app-dev.js")
  pack_js("app.js")
end

task :test do
  system("COVERAGE=1 bundle exec bacon spec/**/*_spec.rb")
end



begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end
