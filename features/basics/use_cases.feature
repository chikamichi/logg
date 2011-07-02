Feature: Basic Logg features

  Logg provides you with simple logging/dispatching facilities.

  Scenario: Use-case
    Given a file named "01-basic_usage/use_cases.rb" with:
    """
    require File.expand_path("../../../lib/logg.rb",  __FILE__)

    class Foo
      include Logg::Machine

      attr_reader :baz

      def initialize
        @baz = 'baz'
        self.class.log.debug "initializing"
      end

      def bar
        log.foo "in #bar"
        puts self.baz
      end
    end

    foo = Foo.new
    foo.bar
    Foo.log.at_class_level "also"
    """
    When I run "ruby 01-basic_usage/use_cases.rb"
    Then the output should contain "initializing"
    And  the output should contain "[foo] in #bar"
    And  the output should contain "baz"
    And  the output should contain "[at_class_level] also"

  Scenario: With a custom logger
    Given a file named "01-basic_usage/custom_loggers.rb" with:
    """
    require File.expand_path("../../../lib/logg.rb",  __FILE__)
    require 'ostruct'

    class Foo
      include Logg::Machine

      log.as(:http_failure) do |response, error_data|
        puts "Net::HTTP failed with #{response.status}\n- response: #{response.body}\n- Error: #{error_data}"
      end

      log.as(:http_success) do |response|
        puts "Net::HTTP #{response.status}"
      end
    end

    # let's say we performed a Net::HTTP request and got a response,
    # which we will just mock here for the sake of simplicity:
    data = :fake_data
    response_KO = OpenStruct.new(:status => 404, :body => 'KO')
    response_OK = OpenStruct.new(:status => 200, :body => 'OK')

    foo = Foo.new
    foo.log.http_failure response_KO, data
    foo.log.http_success response_OK
    """
    When I run "ruby 01-basic_usage/custom_loggers.rb"
    And  the output should contain "Net::HTTP failed with 404\n- response: KO\n- Error: fake_data"
    And  the output should contain "Net::HTTP 200"
