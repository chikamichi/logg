require 'logg'

class Foo2
  include Logg::MachineE

  log.as(:warning) do
    puts "[Warning] something weird happened at #{Time.now}…"
  end
end

Foo2.log.warning