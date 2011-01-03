require File.expand_path("../../../lib/logg.rb",  __FILE__)

class Foo
  include Logg::Er

  logger.as(:warning) do
    puts "[Warning] something weird happened at #{Time.now}…"
  end
end

Foo.logger.warning