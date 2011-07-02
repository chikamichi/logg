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