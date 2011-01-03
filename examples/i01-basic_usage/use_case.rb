require File.expand_path("../../../lib/logg.rb",  __FILE__)

class Foo
  include Logg::Er

  attr_reader :baz

  def initialize
    @baz = 'baz'
    self.class.logger.debug "initializing"
  end

  def bar
    logger.foo "in #bar"
    puts self.baz
  end
end

foo = Foo.new
foo.bar
Foo.logger.at_class_level "also"