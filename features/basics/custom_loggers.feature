Feature:

  One may define custom loggers to streamline the logging process.

  Scenario: the simplest custom logger
    Given a file named "02-custom_loggers/01.rb" with:
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
    When I run "ruby 02-custom_loggers/01.rb"
    Then the output should contain "[Warning] something weird happened at"

  Scenario: with some data
    Given a file named "02-custom_loggers/02.rb" with:
    """
    require File.expand_path("../../../lib/logg.rb",  __FILE__)

    class Foo
      include Logg::Er

      logger.as(:warning) do |message|
        puts "Warning! #{message}"
      end

      logger.as(:error) do |error, note|
        puts "Error! #{error.class}, #{error.message} (#{note})"
      end
    end

    Foo.logger.warning "something weird happen"
    Foo.logger.error Exception.new('FATAL')
    Foo.logger.error Exception.new('FATAL'), 'no user found'
    """
    When I run "ruby 02-custom_loggers/02.rb"
    Then the output should contain "Warning! something weird happen"
    And  the output should contain "Error! Exception, FATAL"
    And  the output should contain "Error! Exception, FATAL (no user found)"
