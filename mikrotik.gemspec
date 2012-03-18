# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mikrotik/version"

Gem::Specification.new do |s|
  s.name        = "mikrotik"
  s.version     = Mikrotik::VERSION
  s.authors     = ["Iain Wilson"]
  s.homepage    = "http://github.com/ominiom/mikrotik"
  s.summary     = %q{A Mikrotik RouterOS API client using EventMachine} 
  s.description = %q{Provides an interface to run commands and collect results from a RouterOS device}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
