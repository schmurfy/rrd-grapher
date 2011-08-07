
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

- you should be able to able to add a new graph in minutes
- the zoom (with mouse drag and drop) load new fresh data so your graph is as exact as possible


- you can decide if the zoom will affect every graph on the page or just one
- 


# Development

If you wan to contribute to this project, here how to do it (in the root folder):

    $ bundle

Now you have all the require gems run guard, it will monitor the sources files
and rebuild the results as you change them (coffeescript, sass).
It will also package all the js files with sprockets in one file.

    $ guard (will take one console)

Last thing you will certainly need is to start a webserver, any should do but
I currently use unicorn

    $ unicorn 

