# encoding: utf-8
require 'logg'
require 'ostruct'

class Foo
  include Logg::Machine

  log.as(:hello) do |who|
    tpl = <<-TPL
= [x.to_s.capitalize, y.to_s].join(' ')
    TPL
    puts render_inline(tpl, :as => :haml, :locals => { :x => :hello, :y => who })
  end
end

Foo.log.hello('World')