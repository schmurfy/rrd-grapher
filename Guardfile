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





require 'bacon'
require 'guard/guard'

module ::Guard
  class Bacon < Guard

    def initialize(watchers=[], options={})
      super
    end

    def start
      puts "Guard::Bacon started."
      true
    end

    # Called on Ctrl-C signal (when Guard quits)
    def stop
      true
    end

    # Called on Ctrl-Z signal
    def reload
      true
    end

    # Called on Ctrl-\ signal
    # This method should be principally used for long action like running all specs/tests/...
    def run_all
      true
    end
    
    SPEC_FILE ||= /_spec\.rb$/.freeze
    FILE_REG  ||= %r{^lib/rrd-grapher/(?:[^/]+/)?(.*)\.rb$}.freeze
    
    def run_spec(path)
      if File.exists?(path)
        puts "     *** Running spec: #{path} ***"
        counters = ::Bacon.run_file(path)
        # system "bundle exec bacon -o TestUnit #{path}"
        # {:installed_summary=>1, :specifications=>19, :depth=>0, :requirements=>30, :failed=>2}
        if counters[:failed] > 0
          Notifier.notify("Specs: #{counters[:failed]} Failures",
              :image => :failed,
              :title => File.basename(path)
            )
        else
          Notifier.notify("Specs: OK",
              :image => :success,
              :title => File.basename(path)
            )
        end
      end
    end
    
    def file_changed(path)
      case
      when path =~ SPEC_FILE    then  run_spec(path)
      when path =~ FILE_REG     then  run_spec("spec/unit/#{$1}_spec.rb")
      end
      
      puts ""
    end
    
    # Called on file(s) modifications
    def run_on_change(paths)
      paths.each do |path|
        file_changed(path)
      end
    end

  end
end


guard 'bacon' do
  watch(%r{^spec/([^/]/)?.*_spec.rb$})
  watch(%r{^lib/rrd-grapher/(?:[^/]+/)?(.*)\.rb$})
end

