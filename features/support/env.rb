#require File.expand_path("../../../lib/logg.rb",  __FILE__)
#path = File.expand_path(File.dirname(__FILE__) + '/../../lib/logg.rb')
#ENV['PATH'] = ENV['PATH'] + ":#{path}"
require 'aruba/cucumber'

Before do
  @dirs = ["examples"]
end
