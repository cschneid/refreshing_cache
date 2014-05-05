# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'refreshing_cache'

Gem::Specification.new do |spec|
  spec.name          = "refreshing_cache"
  spec.version       = RefreshingCache::VERSION
  spec.authors       = ["Chris Schneider"]
  spec.email         = ["chris@christopher-schneider.com"]
  spec.summary       = %q{A hash-like object that attempts to refresh the keys based on some rules}
  spec.description   = %q{A hash-like object that attempts to refresh the keys based on some rules.}
  spec.homepage      = "https://github.com/cschneid/refreshing_cache"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec"
end
