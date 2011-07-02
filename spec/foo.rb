class Foo
  include Logg::Machine
  Logg::ALWAYS_PUTS = false

  attr_reader :test

  def initialize
    @test = :test
  end

  log.as(:warning) do |e, r|
    # actually one can do and return anything in here, be it a String
    # or any Ruby object
    "[W] #{e} => #{r}"
  end

  # One may want to use a gem like unindent or Facet's helper to ease
  # the pain of writing unindented multiline string. Old school style
  # will do for this spec.
  log.as(:a) do |response|
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
    render_inline(tpl, :as => :haml, :data => response)
  end

  log.as(:b) do |response|
    render('spec/tpl/one.haml', :data => response)
  end

  log.as(:c) do |response|
    render('spec/tpl/one', :as => :haml, :data => response)
  end

  log.as(:d) do |response|
    render('spec/tpl/one.customext', :as => :haml, :data => response)
  end

  log.as(:e) do |response|
    render('spec/tpl/two.haml', :data => response, :locals => {:foo => 'bar'})
  end
end
