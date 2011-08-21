
# What is this ?

RRDGrapher is my attempt at designing an application capable of drawing meaningful
dynamic graphs from RRD files.

This project is built as a Rack middleware providing you the with the tools you need to
build you own views as you see fit, the middleware will provide:

- a REST inerface to your rrd files
- a javascript framework to create graphs easily (built on top of jQuery and Flot)
- some basic css to get you started (everything can then be overloaded in your application)

You can have a look at the example_app folder which is a fully working application.

# My goals

The main goal of this project is to allow easy creation of graphs from rrd files stored
by any tool capable of it (the source really does not matter). Here is a features list:

# Features

- you should be able to able to add a new graph in minutes
- the zoom (with mouse drag and drop) load new fresh data so your graph is as exact as possible
- you can decide if the zoom will affect every graph on the page or just one 


# Notifier Demon

This one may go into another gem but lives there for now, I made a monitoring demon to receive
collectd packets and trigger alerts by reacting on the data received.

## What can be monitored ?

Here s what the demon can monitor:

- min/max value : raise an alarm if the value go above or below a <X>
- missing data  : raise an alarm if no data was received for <X> seconds
- clock drift   : raise an alarm if the absolute difference between the timestamp
  inside the packet and the local time is higher then <X> (this suppose that both
  hosts have an UTC clock)

## How to use it

The demon is desgined as a library and require an eventmachine reactor to run, here is a minimal
application using it (check the documentation or the source code for more informations):

``` ruby
require 'rubygems'
require 'bundler/setup'
require 'rrd-grapher/notifier'

puts "Notifier started."

EM::run do
  RRDNotifier::Server.start do |s|
    s.register_alarm("*", "ping", "ping_droprate", :max => 5)
    s.register_alarm("*", "uptime", "uptime", :monitor_presence => 2*60)
    
    s.register_alarm("*", "load", "load", :max => 1, :index => 1)
    s.register_alarm("*", "memory/*", "memory/active", :monitor_presence => 1)
  end
  
end
```



# Development

If you wan to contribute to this project, here how to do it (in the root folder):

    $ bundle

Now you have all the require gems run guard, it will monitor the sources files
and rebuild the results as you change them (coffeescript, sass).
It will also package all the js files with sprockets in one file.

    $ bundle exec guard (will take one console)

You can also force a full rebuild of everything with (coffeescript + sprockets):

    $ rake build

Last thing you will certainly need is to start a webserver, any should do but
I currently use unicorn

    $ unicorn 

