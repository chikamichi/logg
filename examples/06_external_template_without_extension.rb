# encoding: utf-8
require 'logg'
require 'ostruct'
require 'better/tempfile'

class Foo
  include Logg::Machine

  # For the sake of this example, the template file is being created
  # within the custom logger, as a tempfile, but one would rather use
  # a legacy file and streamline this method!
  log.as(:http_response) do |response|
    tpl = <<-TPL
%h2 Query log report
%span.status
  Status:
  = status
%span.body
  Response:
  = body
%br/
    TPL
    Better::Tempfile.open('LoggExample') do |f|
      f.write(tpl)
      f.rewind
      puts render(f.path, :as => :haml, :data => response)
    end
  end
end

response = OpenStruct.new(:status => 200, :body => 'bar')
Foo.log.http_response(response)