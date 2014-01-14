module Pickwick
  module Workers
    module Enrichment
      class Geo
        include Sidekiq::Worker

        sidekiq_options queue:     :enrichment_geo,
                        retry:     3,
                        backtrace: true,
                        throttle:  { threshold: 60, period: 1.minute }

        def perform(options={})
          setup(options)
          get_vacancy
          return unless @vacancy

          get_coordinates
          return unless @coordinates

          update_vacancy
        end

        def setup(options={})
          options.symbolize_keys!
          @options = options
          @id      = @options[:id]
        end

        def get_vacancy
          @vacancy = Pickwick::API.get(@id).body[:vacancies].first rescue nil
        end

        def get_coordinates
          @coordinates = Geocoder.coordinates(__vacancy_address) || Geocoder::Lookup.get(:google).search(__vacancy_address).first.coordinates
        end

        def update_vacancy
          @vacancy[:location][:coordinates] = {}
          @vacancy[:location][:coordinates][:lat] = @coordinates.first
          @vacancy[:location][:coordinates][:lon] = @coordinates.last
          Pickwick::API.store(@vacancy)
        end

        def __vacancy_address
          address = [ @vacancy[:location][:street], @vacancy[:location][:region], @vacancy[:location][:city], @vacancy[:location][:country] ]
          address.compact.join(", ")
        end

      end
    end
  end
end
