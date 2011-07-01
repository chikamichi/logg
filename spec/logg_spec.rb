require 'spec_helper'

class Foo
  include Logg::Er
  Logg::NO_STDOUT = true

  attr_reader :test

  def initialize
    @test = :test
  end
end

class Bar < Foo
  logger.as(:warning) do |e, r|
    "[W] #{e} => #{r}"
  end
end

shared_examples_for "a Logg::Er user" do
  describe "the user (ie. a class)" do
    it "should know about self#logger" do
      u.should respond_to :logger
      u.class.should respond_to :logger
    end
    it "should be able to output a logging message" do
      u.logger.debug("test").should =~ /\[debug\] test/
      u.class.logger.debug("test").should =~ /\[debug\] test/
    end
    it "should retain all of its #initialize behavior" do
      u.test.should == :test
    end

    it "should not know about loggers defined in its subclasses" do
      u.should_not respond_to :warning
    end

    context "should allow to define the logging message using a template" do
      pending "Tilt integration underway"
    end

    # TODO: typically these kind of specs should be Cucumber scenarii,
    # as done within the rspec-core suite. The spec should only test
    # wether logger has #as defined, and what kind of data it returns
    # (String), not the real content
    context "with custom logging handlers defined" do
      subject { Bar.new }
      it "should allow to define a custom logging method" do
        subject.logger.should respond_to :warning
        subject.class.logger.should respond_to :warning
      end
      it "should be able to use the custom logging method" do
        subject.logger.warning("test", "custom").should == "[W] test => custom"
      end
      it "should widespread to the other common logger users" do
        [Foo, Foo.new, Bar, Bar.new].each do |user|
          user.logger.should respond_to :warning
        end
      end
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

  context Foo do
    subject { Foo.new }
    it_should_behave_like "a Logg::Er user" do
      let(:u) { subject }
    end
  end
end
