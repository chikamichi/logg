require File.expand_path("../../lib/logg.rb",  __FILE__)
require 'tempfile'
require 'stringio'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
end

def quietly
  orig_stdout = $stdout.clone
  orig_stderr = $stdout.clone
  $stdout.reopen(File.new('spec_stdout', 'w'))
  $stderr.reopen(File.new('spec_stderr', 'w'))
  yield
  $stdout = orig_stdout
  $stderr = orig_stderr
end
