require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mikrotik"
    gem.summary = %Q{Mikrotik API protocol client in Ruby}
    gem.description = %Q{An implementation of the Mikrotik API protocol in Ruby/EventMachine}
    gem.email = "iain@ominiom.com"
    gem.homepage = "http://github.com/ominiom/mikrotik"
    gem.authors = ["Iain Wilson"]
    gem.files = FileList["lib/*.rb", "lib/*/*.rb", "lib/*/*/*.rb"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
