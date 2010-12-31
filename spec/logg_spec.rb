require 'spec_helper'

class Foo
  include Logg::Er
end

#def try
  #Foo.class_eval { yield }
#end

describe Logg do
  it "should be valid" do
    Logg.should be_a(Module)
  end

  it "should output the logging message" do
    Foo.logger.debug("test").should =~ /\[debug\] test/
  end
end
