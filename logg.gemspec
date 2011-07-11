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
  s.add_dependency 'tilt'
  s.add_dependency 'better'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'metric_fu'
  s.add_development_dependency 'rcov'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-cucumber'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rb-inotify'
  s.add_development_dependency 'libnotify'
end
