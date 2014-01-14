require 'sidekiq'
require 'sidekiq-cron'
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
Sidekiq::Cron::Job.load_from_hash YAML.load_file("config/sidekiq_scheduler.yml")
