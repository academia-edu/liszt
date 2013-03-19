# encoding: UTF-8

if ENV['COVERAGE']
  require "simplecov"
  SimpleCov.start
end

require "minitest/autorun"
require "minitest/spec"
require "minitest/pride"
require "minitest/mock"

require "liszt"
require "redis"
require "logger"
require "pry"

Liszt.redis = Redis.new(:host => "localhost", :port => "10001")

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
    t.boolean "is_foo"
    t.boolean "is_bar"
    t.timestamps
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.integer  "group_id"
    t.boolean  "is_male"
    t.timestamps
  end
end

class Group < ActiveRecord::Base
  acts_as_liszt :sort_by => lambda { |o| o.id },
    :conditions => { :is_foo => true, :is_bar => nil },
    :append_new_items => true
end

class Person < ActiveRecord::Base
  acts_as_liszt :scope => [:group_id, :is_male]
end

class MiniTest::Spec
  class << self
    def setup(symbol = nil, &block)
      if symbol
        before { send symbol }
      else
        before &block
      end
    end

    def teardown(symbol = nil, &block)
      if symbol
        after { send symbol }
      else
        after &block
      end
    end
  end

  include ActiveRecord::TestFixtures

  self.use_instantiated_fixtures = true
  self.use_transactional_fixtures = false
  self.fixture_path = "test/fixtures"

  fixtures :groups, :people
end

if ENV['DEBUG']
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

  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
