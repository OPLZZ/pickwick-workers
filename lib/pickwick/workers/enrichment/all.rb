module Pickwick
  module Workers
    module Enrichment
      class All
        include Sidekiq::Worker

        sidekiq_options queue: :enrichment,
                        retry: false

        def perform(options={})
          options.symbolize_keys!
          @id = options[:id]

          Geo.perform_async(id: @id)
        end

      end
    end
  end
end
