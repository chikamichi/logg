# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "logg"
  s.author = "Jean-Denis Vauguet <jdvauguet@af83.com>"
  s.email = "jdvauguet@af83.com"
  s.homepage = "http://www.github.com/af83/logg"
  s.summary = "A simple logger."
  s.description = "A simple logger for your ruby applications."
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "0.0.1"
end
