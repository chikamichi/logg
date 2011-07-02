Feature: Logg features

  Logg provides simple logging/dispatching facilities.

  Scenario: Basic use-case
    Given a file named "01_basic_logger.rb" with:
    """
    require 'logg'

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
    When I run `ruby 01_basic_logger.rb`
    Then the output should contain "initializing"
    And  the output should contain "[foo] in #bar"
    And  the output should contain "baz"
    And  the output should contain "[at_class_level] also"

  Scenario: The simplest custom logger
    Given a file named "02_simple_custom_logger.rb" with:
    """
    require File.expand_path("../../../lib/logg.rb",  __FILE__)

    class Foo
      include Logg::Er

      logger.as(:warning) do
        puts "[Warning] something weird happened at #{Time.now}…"
      end
    end

    Foo.logger.warning
    """
    When I run `ruby 02_simple_custom_logger.rb`
    Then the output should contain "[Warning] something weird happened at"

  Scenario: Advanced custom loggers
    Given a file named "03_advanced_custom_loggers.rb" with:
    """
    require 'logg'
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
    When I run `ruby 03_advanced_custom_loggers.rb`
    Then the output should contain "Net::HTTP failed with 404\n- response: KO\n- Error: fake_data"
    And  the output should contain "Net::HTTP 200"
