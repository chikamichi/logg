# Logg

A simple logger for your ruby applications.

## Synopsis

Logg is a library which you can use in any ruby program to gain logging features. At the core of Logg is a module, +Logg::Er+, which you may include (mixin) in a class, or extend within another module. This will inject the Logg helpers, so one can do:

    class Foo
      include Logg::Er
    end

    Foo.logger.debug "test!"      # => Fri Dec 31 16:00:09 +0100 2010 | test!
    Foo.new.logger.debug "test…"  # => Fri Dec 31 16:00:09 +0100 2010 | test…
    Foo.new.logger.error "failed" # => Fri Dec 31 16:00:09 +0100 2010 | [error] failed

This illustrates the basic use case, with the default message template: time | [namespace] message.

Many other use cases are available under the `examples/` directory, based on the Cucumber features. Feel free to investigate.

## Custom loggers

Usually, logging engine provide you with a bunch of "levels", such as FATAL, ERROR, WARNING, NOTICE. Logg does not enforce such a convention and rather let you define your own. One may create custom loggers using `Logg::Machine#as`:

    class Foo
      include Logg::Er

      # define the custom logger
      logger.as(:failure) do |data|
        # play with data and render something, somewhere
      end

      # then use it
      logger.failure my_data
    end

The block may take any number of arguments, of any kind. It should "render" a logging message, be it a simple string, or a template (see below). It should render the message to a valid IO endpoint, be it `$stdout`, `$stderr`, a `File`, an `IOString`… and may even render to several endpoints (again, see below).

If you would like to define a custom logger `as`, this method is also available under `_as`.

## Message formatting, templates

As logging is all about building meaningful messages, one should be provided with efficient tools to define how a message is rendered, once the data are available. Logg uses Tilt to help you define how a message looks like and what does it contain. Tilt is a wrapper around several template engines (you may know about ERB, haml, or the raw `String`, but there are many others). Just tell Logg which format you want to use and go ahead.

All supported template formats and rendering options are documented under `examples/` and by the Cucumber features.

    class Foo
      include Logg::Er

      # let's use vanilla ruby code for the first example
      logger.as(:foo) do
        puts "…"
      end

      # what about using inline ERB?
      logger.as(:foo, :render => :erb) do
        $stderr.puts "<%= … %>"
      end

      # now we want to render an external HAML template
      # any data is passed to the template under the same name
      logger.as(:foo, :render => :haml) do |data|
        render('tpl/foo')
      end

      # or even simpler, with an explicit extension
      logger.as(:foo) do |bar, baz|
        render('tpl/foo.haml')
      end
    end

Note that the blocks are executed in the context of the logger, which means `render` is actually `Logg::Machine#render` and will not conflict with any other method. If you would like to define a `logger.render` custom logger, the `render` method is also available as `_render`.

If you want to render to several endpoints, for instance both to `$stderr` and a file, just do it:

    logger.as(:foo) do |data|
      render('tpl/foo', :as => :haml, :to => :stderr)
      render('tpl/foo', :as => :haml, :to => a_file)
    end

The template is memoized so rendering actually takes place only once.

## About the logger backend

When a class mixins the `Logg::Er` module, a `Logg::Machine` is created and associated (if possible, see below) to the base class, to its subclasses and to any instance of those classes. The machine is shared among those objects, which means custom loggers, formats… defined in any of them is available to all the others at runtime.
