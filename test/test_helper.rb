if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start
end

require 'bundler/setup'

require 'test/unit'
require 'shoulda/context'
require 'turn'
require 'mocha/setup'
require 'vcr'
require 'pry'

require 'pickwick-workers'
