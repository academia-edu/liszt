# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

if ENV["BUNDLE_GEMFILE"] =~ /rails2/
  require File.expand_path("../dummy_2.3/config/environment.rb",  __FILE__)
  require 'test_help'
else
  require File.expand_path("../dummy_3.1/config/environment.rb",  __FILE__)
  require "rails/test_help"
end

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
