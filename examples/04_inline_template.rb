# encoding: utf-8
require 'logg'
require 'ostruct'

class Foo
  include Logg::Machine

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
    puts render_inline(tpl, :as => :haml, :data => response)
  end
end

response = OpenStruct.new(:status => 200, :body => 'bar')
Foo.log.http_response(response)