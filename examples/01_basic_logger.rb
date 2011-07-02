# encoding: utf-8
require 'logg'

class Foo
  include Logg::Machine

  attr_reader :baz

  def initialize
    @baz = 'baz'
    self.class.log.debug "initializing"
  end

  def bar
    log.foo "in #bar"
    puts self.baz
  end
end

foo = Foo.new
foo.bar
Foo.log.at_class_level "also"