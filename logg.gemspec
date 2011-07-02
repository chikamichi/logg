# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
require './lib/logg/version'

Gem::Specification.new do |s|
  s.name = "logg"
  s.author = "Jean-Denis Vauguet <jd@vauguet.fr>"
  s.email = "jd@vauguet.fr"
  s.homepage = "http://www.github.com/chikamichi/logg"
  s.summary = "A simple ruby logger."
  s.description = "A simple message dispatcher (aka. logger) for your ruby applications."
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "Guardfile", "README.md", "CHANGELOG.md"]
  s.version = Logg::VERSION
end
