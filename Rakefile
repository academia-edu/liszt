#!/usr/bin/env rake

require 'bundler/gem_tasks'

desc "Install gems for Rails 2.3.14 and Rails 3.1.0"
task :install_bundle do
  system "bundle install --gemfile Gemfile"
  system "bundle install --gemfile Gemfile.rails2"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

def execute(cmd)
  Dir.chdir "test/dummy_2.3"
  system "env RAILS_ENV=test BUNDLE_GEMFILE=../../Gemfile.rails2 bundle exec #{cmd}"
  Dir.chdir "../dummy_3.1"
  system "env RAILS_ENV=test BUNDLE_GEMFILE=../../Gemfile bundle exec #{cmd}"
  Dir.chdir "../.."
end

desc "Create and migrate the test databases for Rails 2.3.14 and Rails 3.1.0"
task :set_up_test_dbs do
  execute "rake db:create"
  execute "rake db:migrate"
end

desc "Open console in Rails 2.3.14 app"
task :console_rails_2 do
  Dir.chdir("test/dummy_2.3")
  system("env RAILS_ENV=test BUNDLE_GEMFILE=../../Gemfile.rails2 bundle exec script/console")
end

desc "Run tests on Rails 2.3.14"
task :test_rails_2 do
  system("env BUNDLE_GEMFILE=Gemfile.rails2 bundle exec rake test")
end

task :default => [:test, :test_rails_2]
