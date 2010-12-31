require 'spec_helper'

class Foo
  include Logg::Er
end

class Bar < Foo
end

describe Logg do
  context Logg do
    def subject; Logg; end
    it { should be_a Module }
  end

  context Logg::Er do
    def subject; Logg::Er; end
    it { should be_a Module }
  end

  context Logg::Machine do
    def subject; Logg::Machine; end
    it { should be_a Module }
  end

  context Foo do
    it "should output the logging message" do
      Foo.logger.debug("test").should =~ /\[debug\] test/
    end

    it "should allow to define the message using a template" do
      pending
    end
  end

  context Bar do
    it "should output the logging message" do
      Bar.logger.debug("test").should =~ /\[debug\] test/
    end
  end
end
