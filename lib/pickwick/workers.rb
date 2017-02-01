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
require 'geocoder'

require 'pickwick/api'
require 'pickwick/workers/feeders/mpsv/parser'
require 'pickwick/workers/feeders/mpsv/processor'

require 'pickwick/workers/enrichment/all'
require 'pickwick/workers/enrichment/geo'

require 'pickwick/workers/version'

Geocoder.configure(
  lookup:       :nominatim,
  always_raise: :all,
  units:        :km,
  timeout:      30,
  cache:        Redis.connect(url: (ENV['SIDEKIQ_REDIS_URL'] || 'redis://127.0.0.1:6379'), db: 7)
)

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, storage: :redis
  end
  config.average_scheduled_poll_interval = 0.5
  config.redis                           = { url: ENV["SIDEKIQ_REDIS_URL"] || 'redis://localhost:6379' }
end

Sidekiq.configure_client do |config|
  config.redis         = { url: ENV["SIDEKIQ_REDIS_URL"] || 'redis://localhost:6379' }
end

Sidekiq::Cron::Job.load_from_hash YAML.load_file("config/sidekiq_scheduler.yml")
