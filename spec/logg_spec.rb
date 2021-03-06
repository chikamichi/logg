require 'spec_helper'
require 'ostruct'
require 'foo'

shared_examples_for "a Logg::Machine user" do
  describe "the user (ie. a class)" do
    it "should know about self#log" do
      u.should respond_to :log
      u.class.should respond_to :log
    end

    it "should be able to output a logging message" do
      u.log.debug("test").should =~ /\[debug\] test/
      u.class.log.debug("test").should =~ /\[debug\] test/
    end

    it "should retain all of its #initialize behavior" do
      u.test.should == :test
    end

    it "should not know about loggers defined in its subclasses" do
      u.should_not respond_to :warning
    end

    context "with custom loggers defined" do
      it "should allow to define a custom inline logging method" do
        subject.log.should respond_to :warning
        subject.class.log.should respond_to :warning
        subject.log.warning("test", "custom").should == "[W] test => custom"
      end

      context "message templating" do
        let(:response) do
          OpenStruct.new(:status => 200, :body => 'toto')
        end
        let(:expected) do
          %Q{<h2>Query log report</h2>
<span class='status'>\n  Status:\n  #{response.status}\n</span>
<span class='body'>\n  Response:\n  #{response.body}\n</span>
<br />
}
        end
        let(:expected2) do
          expected + "bar\n"
        end

        it "should support inline templates" do
          subject.log.a(response).should == expected
        end
        it "should support templates using a file with an extension" do
          subject.log.b(response).should == expected
        end
        it "should support templates using a file with no extension but providing a syntax type" do
          subject.log.c(response).should == expected
        end
        it "should support templates using a file with a custom extension and a syntax type" do
          subject.log.d(response).should == expected
        end
        it "should support templates with locals along the rendering context" do
          subject.log.e(response).should == expected2
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

  context Logg::Dispatcher do
    def subject; Logg::Dispatcher; end
    it { should be_a Class }
    describe '#as' do
      it "should be provided the logger's name" do
        lambda { subject.new.as }.should raise_error ArgumentError
      end
      it "should be provided a block defining the logger" do
        lambda { subject.new.as(:toto) }.should raise_error ArgumentError, /missing/i
      end
    end
  end

  context Logg::Machine do
    def subject; Logg::Machine; end
    it { should be_a Module }
  end

  context Foo do
    subject { Foo.new }
    it_should_behave_like "a Logg::Machine user" do
      let(:u) { subject }
    end
  end
end
