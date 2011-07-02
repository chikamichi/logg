# Logg

A simple message dispatcher (aka. logger) for your Ruby applications.

## Install

``` bash
$ gem install logg
```

## Synopsis

Logg is a library providing generic logging features. At the core of Logg is a module, `Logg::Machine`, which you may include (mixin) in a class, or extend within another module. This will inject the Logg helpers, so one can write something like this:

``` ruby
class Foo
  include Logg::Machine
end

Foo.log.debug "test!"      # => Fri Dec 31 16:00:09 +0100 2010 | [debug] test!
Foo.new.log.debug "test…"  # => Fri Dec 31 16:00:09 +0100 2010 | [debug] test…
Foo.new.log.error "failed" # => Fri Dec 31 16:00:09 +0100 2010 | [error] failed
```

You may also just instantiate a Logg dispatcher. This is less intrusive, no
mixin involved, allow for changing the dispatcher's name and have several
loggers lurking around:

``` ruby
report = Logg::Dispatcher.new
report.failure 'danger' # => "2011-07-02 20:27:01 +0200 | [failure] danger"
```

``` ruby
class Foo
  attr_reader :report

  def initialize
    @report = Logg::Dispatcher.new
  end

  def bar
    report.something 'important'
  end
end
Foo.new.bar # => "2011-07-02 20:27:01 +0200 | [something] important"
```

This illustrates the basic use cases. The default logging format is a string
sent to `$stdout`, formatted as `time | [namespace] message` where "namespace" is the method called on the logger.

But this is only the default implementation of the message dispatcher. Many other examples are available under the `examples/` directory (based on the Cucumber `features/`). The next part of this README explains some of those use-cases.

## Custom loggers

Usually, logging engines provide you with a bunch of "log levels", such as FATAL, ERROR, WARNING, NOTICE. Logg does not enforce such a convention and rather let you define your own, if required, but does not enforce you to do so. More generally, one may create custom loggers using `Logg::Dispatcher#as`:

``` ruby
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
```

`as` expects a mandatory block, which may take any number of arguments, of any kind. Within the block, it is expected you will "log" somehow, but actually you are free to perform anything. You may output a simple string on $stdout, call an external API through HTTP, send an email, or even render a template (see below): that's just legacy ruby code in here! All in all, Logg is just a mega-method-definition-machine, aimed at logging—but feel free to use it the way you like (dispatching events, for instance).

Soon to come: the possibility to change `#log` for any other valid method name.

Note: if you would like to define a custom logger under the name `#as`, the helper method is also available under the `#_as` alias.

## Message formatting, templates

Logging is all about building meaningful messages. You may also want to log to
the tty, a file and send an email on top of that, and each one of those output
channels would benefit from using a different data representation. One should
thus be provided with efficient tools to define how a message is rendered in
particular context. Logg makes use of [Tilt](https://github.com/rtomayko/tilt)
to help you format your data. [Tilt](https://github.com/rtomayko/tilt) is a wrapper around several template engines (you may know about ERB or haml, but there are many others). Just tell Logg which format you want to use and go ahead! The dispatching logic is of your responsability.

For more details, see `examples/` and read/run the Cucumber `features/` (command: `cucumber features`).

``` ruby
class Foo
  include Logg::Machine

  # let's use vanilla ruby code for the first example: output the
  # message to $stdout using #puts
  log.as(:foo) do
    puts "something really important happened"
  end
  log.foo # => "something really important happened" on $stdout

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
  # note we expect two parameters for this logger
  log.as(:http_response) do |response, params|
    output = render('tpl/foo.haml', :data => response, :locals => { :params => params})
    # do something with output, for instance, send a mail notification when not a 200
  end
  log.http_response(resp, request.params) # performs the block, really
end
```

If you want to render to several logging endpoints, and send a mail on top of that, just do it within the block!

Both `#render_inline` and `#render` follow [Tilt](https://github.com/rtomayko/tilt)'s implementation. The `:data`
object is any Ruby object which be promoted as `self` when rendering the
template. In the last example, if `foo.haml` where to contain calls to
methods such as `status` or `body`, this would mean running `response.status`
and `response.body` within the template. The `:locals` are additional
variables one may need to interpolate the template. In the last example, we
are passing the request parameters along the response object. You basically
define your loggers the way you want (see `Advice` section below for some
insight).

## Dispatching helpers

TODO: provide helpers for message dispatching/logging, levels managment and the like.

## About the implementation

  * When a class mixins the `Logg::Machine` module, a `Logg::Dispatcher` instance is created and associated (if possible, see below) to the receiving class,
through method injection.
* The custom loggers blocks are runned in the context of a `Logg::Dispatcher::Render` class, so be aware you must inject in the closure any data you would require. This is by design so as to keep the logger's logic separated from the application burden, enforcing explicit control over the data payloads.
  * If this is just too much a burden for you, you may avoid mixin `Logg::Machine` and just make use of the `Render` core implementation, by instantiating a new `Logg::Dispatcher` as illustrated in the Synopsis section above.

## Advice

When using MRI 1.9.2 or equivalent implementations, you can now define closure with dynamic params:

``` ruby
log.as(:report) do |name = 'toto', *args|
  puts name
  puts args
end

log.report # => toto
           #    []
log.report('joe') # => joe
                  #    []
log.report('joe', {:foo => :bar}, 1) # => joe
                                     #    [{:foo => :bar}, 1]
```

It also support blocks as closure parameters ([more details](http://www.igvita.com/2011/02/03/new-ruby-19-features-tips-tricks/)). All of this allows for building super-dynamic custom loggers.
