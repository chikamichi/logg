require 'spec_helper'

class Foo
  include Logg::Er

  attr_reader :test

  def initialize
    @test = :test
  end
end

class Bar < Foo
end

shared_examples_for "a Logg::Er user" do
  describe "the class" do
    it "should know about self#logger" do
      u.should respond_to :logger
    end
  end
end

quietly do
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
      it "should output the logging message" do
        subject.logger.debug("test").should =~ /\[debug\] test/
        subject.class.logger.debug("test").should =~ /\[debug\] test/
      end

      it "should retain all of its initialize behavior" do
        subject.test.should == :test
      end

      it "should allow to define the message using a template" do
        pending "Tilt integration underway"
      end

      # TODO: typically these kind of specs should be Cucumber scenarii,
      # as done within the rspec-core suite. The spec should only test
      # wether logger has #as defined, and what kind of data it returns
      # (String), not the real content
      context "with custom logging handlers" do
        before :all do
          class Baz < Bar
            logger.as(:warning) do |e, r|
              "[W] #{e} => #{r}"
            end
          end
        end
        subject { Baz.new }
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

    context Bar, "subclass" do
      subject { Bar.new }
      it_should_behave_like "a Logg::Er user" do
        let(:u) { subject }
      end
      it "should output the logging message" do
        subject.logger.debug("test").should =~ /\[debug\] test/
        subject.class.logger.debug("test").should =~ /\[debug\] test/
      end
    end
  end
end

