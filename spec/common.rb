$:.reject! { |e| e.include? 'TextMate' }
require 'rubygems'

puts "Testing with ruby #{RUBY_VERSION} and rubygems #{Gem::VERSION}"
puts "Working path: #{Dir.pwd}"

require 'bundler/setup'
require 'bacon'
require 'mocha'
require 'factory_girl'


require File.expand_path('../factories', __FILE__)

ROOT = File.expand_path('../../', __FILE__)

if (RUBY_VERSION >= "1.9") && ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/gems/'
    add_filter '/spec/'
    add_filter 'default_user_handler.rb'
  
    root(ROOT)
  end
end


def with(what)
  yield(what)
end


module Bacon
  module MochaRequirementsCounter
    def self.increment
      Counter[:requirements] += 1
    end
  end
  
  class Context
    include Mocha::API
    
    alias_method :it_before_mocha, :it
    
    def it(description)
      it_before_mocha(description) do
        begin
          mocha_setup
          yield
          mocha_verify(MochaRequirementsCounter)
        rescue Mocha::ExpectationError => e
          raise Error.new(:failed, "#{e.message}\n#{e.backtrace[0...10].join("\n")}")
        ensure
          mocha_teardown
        end
      end
    end
  end
end

unless ENV['COVERAGE']
  def focus(test_label)
    # silence_warnings do
      Bacon.const_set(:RestrictName, %r{#{test_label}})
    # end
  end
end

Bacon.summary_on_exit()
