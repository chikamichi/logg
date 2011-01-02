require 'logg'

class Foo
  include Logg::Er

  attr_read :bar

  def initialize
    logger.debug "initializing"
    @bar = 'bar'
  end

  def baz
    logger.foo "in #baz"
    puts bar
  end
end

f = Foo.new
f.baz