require 'spec_helper'

class Foo
  include Logg::Er
end

class Bar < Foo
end

shared_examples_for "a Logg::Er user" do
  describe "the class" do
    it "should know about self#logger" do
      u.should respond_to?(:logger)
    end
  end
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

  context Foo, "instance" do
    subject { Foo.new }
    #it_should_behave_like "a Logg::Er user" do
      #let(:u) { subject }
    #end
    it "should output the logging message" do
      subject.logger.debug("test").should =~ /\[debug\] test/
      subject.class.logger.debug("test").should =~ /\[debug\] test/
    end

    it "should allow to define the message using a template" do
      pending
    end
  end

  context Bar, "instance" do
    subject { Bar.new }
    it "should output the logging message" do
      subject.logger.debug("test").should =~ /\[debug\] test/
      subject.class.logger.debug("test").should =~ /\[debug\] test/
    end
  end
end
