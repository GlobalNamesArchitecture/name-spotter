$:.push File.expand_path("../lib", __FILE__)

require "name-spotter/version"

Gem::Specification.new do |gem|
  gem.name = "name-spotter"
  gem.homepage = "http://github.com/GlobalNamesArchitecture/name-spotter"
  gem.version = NameSpotter::VERSION
  gem.authors = ["Anthony Goddard", "Chuck Ha",
               "Dmitry Mozzherin", "David Shorthouse"]
  gem.license = "MIT"
  gem.summary = "Scientific names finder"
  gem.description = %q|The gem searches for scientific names in texts using
                     socket servers running TaxonFinder (by Patrick Leary)
                     and NetiNeti (by Lakshmi Manohar Akella)|
  gem.email = "dmozzherin@gmail.com"

  gem.files = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency "rake", "~> 10.5"
  gem.add_runtime_dependency "rest-client", "~> 1.8"
  gem.add_runtime_dependency "nokogiri", "~> 1.6"
  gem.add_runtime_dependency "builder", "~> 3.1"
  gem.add_runtime_dependency "json", "~> 1.8"
  gem.add_runtime_dependency "unicode_utils", "~> 1.4"
  gem.add_runtime_dependency "unsupervised-language-detection", "~> 0.0.6"
  gem.add_development_dependency "rspec", "~> 3.1"
  gem.add_development_dependency "bundler", "~> 1.10"
  gem.add_development_dependency "byebug", "~> 8.2"
end

