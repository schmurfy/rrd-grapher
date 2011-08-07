# -*- encoding: utf-8 -*-

require File.expand_path('../lib/rrd-grapher/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "rrd-grapher"
  s.version     = RRDGRapher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julien Ammous"]
  s.email       = []
  s.homepage    = ""
  s.summary     = %q{Graphing toolkit for RRD}
  s.description = s.summary

  s.rubyforge_project = "rrd-grapher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("sinatra",     "~> 1.2.6")
  s.add_dependency("sass",        "~> 3.1.5")
  s.add_dependency("rrd-ffi",     "~> 0.2.7")
  s.add_dependency("rest-client", "~> 1.6.3")
  s.add_dependency("i18n")
  
  
  # s.add_development_dependency("jasmine",             "~> 1.0.2.1")
  s.add_development_dependency("jasmine",             "~> 1.1.0.rc3")
  s.add_development_dependency("bacon",               "~> 1.1.0")
  s.add_development_dependency("mocha",               "~> 0.9.12")
  s.add_development_dependency("simplecov",           "~> 0.4.2")
  s.add_development_dependency("coffee-script",       "~> 2.2.0")
  s.add_development_dependency("therubyracer",        "~> 0.9.2")
  s.add_development_dependency("guard-coffeescript",  "~> 0.3.2")
  s.add_development_dependency("guard-livereload",    "~> 0.2.1")
  s.add_development_dependency("guard-sprockets",     "~> 0.1.4")
  s.add_development_dependency("rb-fsevent")
  s.add_development_dependency("growl")
  s.add_development_dependency("rake")
end
