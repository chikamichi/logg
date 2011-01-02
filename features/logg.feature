Feature: Basic Logg features

  Logg provides you with simple logging facilities.

  Scenario: Use-case 
    Given a file named "use-case_logg.rb" with:
    """
    require File.expand_path("../../lib/logg.rb",  __FILE__)
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
    """
    When I run "ruby use-case_logg.rb"
    Then the output should contain "initializing"
    And  the output should contain "[foo] in #bar"
    And  the output should contain "[at_class_level] also"
