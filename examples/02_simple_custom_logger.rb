# encoding: utf-8
require 'logg'

class Foo
  include Logg::Machine

  log.as(:warning) do
    puts "[Warning] something weird happened at #{Time.now}…"
  end
end

Foo.log.warning