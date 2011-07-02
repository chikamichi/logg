# Logg

A simple message dispatcher (aka. logger) for your Ruby applications.

## Synopsis

Logg is a library providing generic logging features. At the core of Logg is a module, `Logg::Machine`, which you may include (mixin) in a class, or extend within another module. This will inject the Logg helpers, so one can write something like this:

    class Foo
      include Logg::Machine
    end

    Foo.log.debug "test!"      # => Fri Dec 31 16:00:09 +0100 2010 | [debug] test!
    Foo.new.log.debug "test…"  # => Fri Dec 31 16:00:09 +0100 2010 | [debug] test…
    Foo.new.log.error "failed" # => Fri Dec 31 16:00:09 +0100 2010 | [error] failed

This illustrates the basic use case, with the default message format being: `time | [namespace] message` where namespace is the method called on the logger.

Many other use cases are available under the `examples/` directory, based on the Cucumber `features/`. This README explains some of them.

## Custom loggers

Usually, logging engines provide you with a bunch of "log levels", such as FATAL, ERROR, WARNING, NOTICE. Logg does not enforce such a convention and rather let you define your own, if required, but does not enforce you to do so. More generally, one may create custom loggers using `Logg::Dispatcher#as`:

    class Foo
      include Logg::Machine

      # let's define a custom logger
      log.as(:failure) do |data|
        # play with data and render/do something, somewhere: output a String,
        # send an email, anything you want.
      end

      # then use it!
      log.failure my_data
    end

`as` expects a mandatory block, which may take any number of arguments, of any kind. Within the block, it is expected you will "log" somehow, but actually you are free to perform anything. You may output a simple string on $stdout, call an external API through HTTP, send an email, or even render a template (see below): that's just legacy ruby code in here! All in all, Logg is just a mega-method-definition-machine, aimed at logging—but feel free to use it the way you like (dispatching events, for instance).

Soon to come: the possibility to change `#log` for any other valid method name.

Note: if you would like to define a custom logger under the name `#as`, the helper method is also available under the `#_as` alias.

## Message formatting, templates

Logging is all about building meaningful messages. You may also want to log to the tty, a file and send an email on top of that, and each one of those output channels would benefit from using a different data representation. One should thus be provided with efficient tools to define how a message is rendered in particular context. Logg makes use of Tilt to help you format your data. Tilt is a wrapper around several template engines (you may know about ERB or haml, but there are many others). Just tell Logg which format you want to use and go ahead! The dispatching logic is of your responsability.

For more details, see `examples/` and read/run the Cucumber `features/` (command: `cucumber features`).

    class Foo
      include Logg::Machine

      # let's use vanilla ruby code for the first example: output the
      # message to $stdout using #puts
      log.as(:foo) do
        puts "something really important happened"
      end

      # you may also define a template within the block, render it and
      # use the result.
      # (Keep in mind that this kind of template with heavy code is considered bad practice ;))
      log.as(:foo) do |data|
        tpl = "Data: <%= self.map { |k,v| puts k.to_s + v.to_s } %>"
        puts render_inline(tpl, :as => :erb, :data => data)
      end
      log.foo({:foo => :bar}) # => "Data: foobar"

      # now we want to render an external HAML template, providing its path with
      # or withouth the .haml extension (if not provided, the :as option is mandatory)
      log.as(:http_response) do |resp|
        output = render('tpl/foo', :as => :haml, :data => resp)
        # do something with output
      end
    end

If you want to render to several logging endpoints, and send a mail on top of that, just do it within the block!

## Dispatching helpers

TODO: provide helpers for message dispatching/logging.

## About the logger backend

When a class mixins the `Logg::Machine` module, a `Logg::Dispatcher` instance is created and associated (if possible, see below) to the base class, to its subclasses and to any instance of those classes. The machine is shared among those objects, which means custom loggers, formats… defined in any of them is available to all the others at runtime.
