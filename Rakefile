require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = "sinatra-minify"
    s.authors     = ["Rico Sta. Cruz", "Cyril David", "Sinefunc, Inc."]
    s.email       = "info@sinefunc.com"
    s.summary     = "CSS/JS compressor for Sinatra"
    s.homepage    = "http://www.github.com/sinefunc/sinatra-minify"
    s.description = "sinatra-minify is an extension for Sinatra to compress assets."
    s.add_development_dependency 'rack-test'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sinatra-minify #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :minify do
  desc "Builds the example files in test/fixtures/exampleapp"
  task :build_example do
    $:.unshift File.dirname(__FILE__) + '/lib'

    require 'test/fixtures/exampleapp/app'
    puts "Building..."

    files = Sinatra::Minify::Package.build(App)
    files.each { |f| puts " * #{File.basename f}" }
    puts "Construction complete!"
  end
end
