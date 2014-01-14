# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pickwick/workers/version'

Gem::Specification.new do |spec|
  spec.name          = "pickwick-workers"
  spec.version       = Pickwick::Workers::VERSION
  spec.authors       = ["Vojtech Hyza"]
  spec.email         = ["vhyza@vhyza.eu"]
  spec.description   = %q{Feeders and Enrichment for damepraci.eu project}
  spec.summary       = %q{Feeders and Enrichment for damepraci.eu project}
  spec.homepage      = "http://damepraci.eu"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "sidekiq"
  spec.add_dependency "sidekiq-cron"
  spec.add_dependency "rubyzip"
  spec.add_dependency "faraday"
  spec.add_dependency "nokogiri"
  spec.add_dependency "unicode_utils"
  spec.add_dependency "multi_json"
  spec.add_dependency "oj"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "shoulda-context"
  spec.add_development_dependency "turn"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "simplecov"
end
