# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "liszt/version"

Gem::Specification.new do |s|
  s.name        = "liszt"
  s.version     = Liszt::VERSION
  s.authors     = ['Ryan Fitzgerald']
  s.email       = %w{rfitz@academia.edu}
  s.homepage    = "http://academia.edu"
  s.summary     = %q{ActiveRecord sorting using Redis lists}
  s.description = %q{Liszt is an alternative to acts_as_list and sortable that uses atomic Redis operations to maintain scoped ordering information for ActiveRecord objects.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w{lib}

  s.add_runtime_dependency "activerecord", ">= 3.0.0"
  s.add_runtime_dependency "redis"

  s.add_development_dependency "minitest"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rdiscount"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "yard"
end
