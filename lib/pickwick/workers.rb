require 'sidekiq'
require 'sidekiq-failures'
require 'sidekiq/limit_fetch'
require 'sidekiq-cron'
require 'sidekiq-throttler'
require 'faraday'
require 'zip'
require 'nokogiri'
require 'unicode_utils'
require 'multi_json'
require 'oj'

require 'pickwick/api'
require 'pickwick/workers/feeders/mpsv/parser'
require 'pickwick/workers/feeders/mpsv/processor'
require 'pickwick/workers/version'
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, storage: :redis
  end
  config.poll_interval = 0.5
end

Sidekiq::Cron::Job.load_from_hash YAML.load_file("config/sidekiq_scheduler.yml")
