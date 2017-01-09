require 'test_helper'

module Pickwick
  module Workers
    module Enrichment
      class AllTest < Minitest::Test
        context "Enrichment" do

          setup do
            @job = All.new
          end

          should "enqueue Geo job" do
            Geo.expects(:perform_async).with(id: 123)
            @job.perform(id: 123)
          end

        end
      end
    end
  end
end
