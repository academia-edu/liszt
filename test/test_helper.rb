# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

if ENV["BUNDLE_GEMFILE"] =~ /rails2/
  require File.expand_path("../dummy_2.3/config/environment.rb",  __FILE__)
  require 'test_help'
else
  require File.expand_path("../dummy_3.1/config/environment.rb",  __FILE__)
  require "rails/test_help"
end

if ENV["DEBUG_REDIS"] =~ /y/
  class Redis
    module Connection
      class Ruby
        def write(command)
          $stderr.puts "\n<- #{command}"
          @sock.write(build_command(command))
        end

        def format_reply(reply_type, line)
          reply = case reply_type
          when MINUS    then format_error_reply(line)
          when PLUS     then format_status_reply(line)
          when COLON    then format_integer_reply(line)
          when DOLLAR   then format_bulk_reply(line)
          when ASTERISK then format_multi_bulk_reply(line)
          else raise ProtocolError.new(reply_type)
          end
          $stderr.puts "-> #{reply}"
          reply
        end
      end
    end
  end
end

class Array
  def swap(i1, i2)
    self[i1], self[i2] = self[i2], self[i1]
  end
end

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
