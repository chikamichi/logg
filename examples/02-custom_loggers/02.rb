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