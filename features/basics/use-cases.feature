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

  Scenario: With custom guards
    Given a file named "custom_guard.rb" with:
    """
    require File.expand_path("../../lib/logg.rb",  __FILE__)
    require 'ostruct'

    class Foo
      include Logg::Er

      logger.as(:http_failure) do |response, data|
        puts "Net::HTTP failed with #{response.status}\n- response: #{response.body}\n- data: #{data}"
      end

      logger.as(:http_success) do |response|
        puts "Net::HTTP #{response.status}"
      end
    end
 
    # let's say we perform a Net::HTTP request and get a response,
    # which we will just mock for the sake of this example:
    data = :fake_data
    response_KO = OpenStruct.new(:status => 404, :body => 'KO')
    response_OK = OpenStruct.new(:status => 200, :body => 'OK')

    foo = Foo.new
    foo.logger.http_failure response_KO, data
    foo.logger.http_success response_OK
    """
    When I run "ruby custom_guard.rb"
    And  the output should contain "Net::HTTP failed with 404\n- response: KO\n- data: fake_data"
    And  the output should contain "Net::HTTP 200"
