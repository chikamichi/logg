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