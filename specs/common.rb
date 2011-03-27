$:.reject! { |e| e.include? 'TextMate' }
require 'rubygems'

puts "Testing with ruby #{RUBY_VERSION} and rubygems #{Gem::VERSION}"
puts "Working path: #{Dir.pwd}"

require 'bundler/setup'
require 'bacon'
require 'mocha'
require 'factory_girl'
require 'simplecov'


# require File.join(File.dirname(__FILE__), 'factories.rb')

ROOT = File.expand_path('../../', __FILE__)

SimpleCov.start do
  add_filter '/gems/'
  add_filter '/specs/'
  
  root(ROOT)
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


def focus(test_label)
  silence_warnings do
    Bacon.const_set(:RestrictName, %r{#{test_label}})
  end
end

def focus_context(test_label)
  silence_warnings do
    Bacon.const_set(:RestrictContext, %r{#{test_label}})
  end
end

Bacon.summary_on_exit()
