# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "name-spotter"
  gem.homepage = "http://github.com/GlobalNamesArchitecture/name-spotter"
  gem.license = "MIT"
  gem.summary = %Q{Scientific names finder}
  gem.description = %Q{The gem searches for scientific names in texts using socket servers running TaxonFinder (by Patrick Leary) and NetiNeti (by Lakshmi Manohar Akella)}
  gem.email = "dmozzherin@gmail.com"
  gem.authors = ["Ryan Schenk", "Anthony Goddard", "Chuck Ha", "Dmitry Mozzherin"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => :spec

