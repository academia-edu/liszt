# encoding: UTF-8

require "test/unit"
require "shoulda-context"
require "liszt"
require "redis"

Liszt.redis = Redis.new(:host => "localhost", :port => "10001")

if ENV['DEBUG_REDIS']
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

# set up in-memory database

ENV['RAILS_ENV'] ||= 'test'

require "active_record"
require "active_record/test_case"

ActiveRecord::Base.configurations = {
  "test" => { "adapter" => "sqlite3", "database" => ":memory:" }
}

ActiveRecord::Base.establish_connection "test"

ActiveRecord::Schema.define do
  create_table "groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.integer  "group_id"
    t.boolean  "is_male"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end

class Group < ActiveRecord::Base
end

class Person < ActiveRecord::Base
  acts_as_liszt :scope => [:group_id, :is_male]
end

class Liszt::TestCase < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  self.use_instantiated_fixtures = true
  self.use_transactional_fixtures = false
  self.fixture_path = "test/fixtures"

  fixtures :groups, :people
end
