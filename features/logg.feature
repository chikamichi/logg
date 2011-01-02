Feature: Basic Logg features

  Logg provides you with simple logging facilities.

  Scenario: Use-case 
    Given a file named "use-case_logg.rb" with:
    """
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
    """
    When I run "ruby use-case_logg.rb"
    Then the output should contain "initializing"
    And  the output should contain "[foo] in #baz"
