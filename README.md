# Logg

A simple logger for your ruby applications.

## Synopsis

Logg is a library which you can use in any ruby program to ease the pain of logging, in a standardized way, your debug/warning/whatever messages. At the core of Logg is a module, +Logg::Er+, which you may include (mixin) in a class or extend within another module to inject Logg helpers, so one can do:

    class Foo
      include Logg::Er
    end

    Foo.logger.debug "test!"      # => Fri Dec 31 16:00:09 +0100 2010 | test!
    Foo.new.logger.debug "test…"  # => Fri Dec 31 16:00:09 +0100 2010 | test…
    Foo.new.logger.error "failed" # => Fri Dec 31 16:00:09 +0100 2010 | [error] failed

This illustrates the basic use case, with the default message template: time | [namespace] message.

## Message formatting

As logging is all about building meaningful message, one should have efficient tools to define how a message is rendered. Logg makes use of a simple templating system, XXXX, to help you define how a message looks like and what does it contain.

    class Foo
      include Logg::Er

      # Define the template as pure ruby code, or use XXXXX: both
      # returns a string.
      #
      # Let's use ruby code for this example. Define a 'warning' namespace.
      logger.as(:warning) do |e, r|
        "#{e.class} raised by #{r.status}: #{r.body || e.message}"
      end

      # Let's define bar() as a method which performs a GET request
      # on a remote API…
      def bar
        @response = get(@url)
      rescue => e
        logger.warning e, @response 
      end
    end

    # if the request fails…
    Foo.new.bar # => 

blabla…
