require 'spec_helper'
require 'ostruct'

class Foo
  include Logg::Er

  attr_reader :test

  def initialize
    @test = :test
  end

  logger.as(:warning) do |e, r|
    "[W] #{e} => #{r}"
  end

  # One may want to use a gem like unindent or Facet's helper to ease
  # the pain of writing unindented multiline string. Old school style
  # will do for this spec.
  logger.as(:a) do |response|
    tpl = <<-TPL
%h2 Query log report
%span.status
  Status:
  = status
%span.body
  Response:
  = body
%br/
    TPL
    render_inline(tpl, :as => :haml, :data => response)
  end

  logger.as(:b) do |response|
    render('spec/tpl/one.haml', :data => response)
  end

  logger.as(:c) do |response|
    render('spec/tpl/one', :as => :haml, :data => response)
  end

  logger.as(:d) do |response|
    render('spec/tpl/one.customext', :as => :haml, :data => response)
  end

  logger.as(:e) do |response|
    render('spec/tpl/two.haml', :data => response, :locals => {:foo => 'bar'})
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

    context "with custom loggers defined" do
      it "should allow to define a custom inline logging method" do
        subject.logger.should respond_to :warning
        subject.class.logger.should respond_to :warning
        subject.logger.warning("test", "custom").should == "[W] test => custom"
      end

      context "message templating" do
        let(:response) do
          response = OpenStruct.new
          response.status = 200
          response.body   = 'toto'
          response
        end
        let(:expected) do
          expected  = "<h2>Query log report</h2>\n"
          expected += "<span class='status'>\n  Status:\n  #{response.status}\n</span>\n"
          expected += "<span class='body'>\n  Response:\n  #{response.body}\n</span>\n"
          expected += "<br />\n"
          expected
        end
        let(:expected2) do
          expected + "bar\n"
        end

        it "should support inline templates" do
          subject.logger.a(response).should == expected
        end
        it "should support templates using a file with an extension" do
          subject.logger.b(response).should == expected
        end
        it "should support templates using a file with no extension but providing a syntax type" do
          subject.logger.c(response).should == expected
        end
        it "should support templates using a file with a custom extension and a syntax type" do
          subject.logger.d(response).should == expected
        end
        it "should support templates with locals along the rendering context" do
          subject.logger.e(response).should == expected2
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
