if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

require 'bundler/setup'

require 'minitest/autorun'
require 'minitest/reporters'
require 'shoulda/context'
require 'mocha/setup'
require 'webmock'
require 'vcr'

require 'pickwick-workers'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

VCR.configure do |c|
  c.cassette_library_dir = File.dirname(__FILE__) + '/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

def fixture_file(name)
  File.read File.expand_path("../fixtures/#{name}", __FILE__)
end

def mocked_faraday_response(status, body)
  stub(status: status, body: body.is_a?(Hash) ? body.to_json : body)
end
