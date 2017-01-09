require 'test_helper'

module Pickwick
  module Workers
    module Enrichment
      class GeoTest < Minitest::Test
        context "GEO enrichment" do

          setup do
            @job     = Geo.new
            @address = 'Lidická tř. 1104/177, České Budějovice, Czech Republic'

            @job.setup(id: 'd75b0fd410980f87e812af6b4dfcffc72eaa52f2')
          end

          should "download vacancy via API" do
            VCR.use_cassette('vacancy') do
              @job.get_vacancy

              vacancy = @job.instance_variable_get "@vacancy"

              assert_equal 'd75b0fd410980f87e812af6b4dfcffc72eaa52f2', vacancy[:id]
              assert_equal 'Lidická tř. 1104/177',                     vacancy[:location][:street]
            end
          end

          should "generate address for geocoding" do
            VCR.use_cassette('vacancy') do
              @job.get_vacancy
              assert_equal @address, @job.__vacancy_address
            end
          end

          should "get coordinates for vacancy location" do
            @job.expects(:__vacancy_address).returns(@address)
            Geocoder.expects(:coordinates).with(@address).returns([48.9524099, 14.4670136])
            
            @job.get_coordinates

            coordinates = @job.instance_variable_get '@coordinates'
            assert_equal [48.9524099, 14.4670136], coordinates
          end

          should "enrich vacancy with downloaded coordinates" do
            Geocoder.expects(:coordinates).with(@address).returns([48.9524099, 14.4670136])
            Pickwick::API.expects(:store).with do |document|
              assert_equal({:lat=>48.9524099, :lon=>14.4670136}, document[:location][:coordinates])
            end

            VCR.use_cassette('vacancy') do
              @job.perform('id' => 'd75b0fd410980f87e812af6b4dfcffc72eaa52f2')
            end
          end

          should "exit if vacancy not found" do
            Pickwick::API.expects(:get).with('123').returns(nil)
            @job.expects(:get_coordinates).never

            @job.perform('id' => '123')
          end

          should "exit if coordinates are not returned" do
            @job.expects(:get_coordinates).returns(nil)
            @job.expects(:update_vacancy).never

            VCR.use_cassette('vacancy') do
              @job.perform('id' => 'd75b0fd410980f87e812af6b4dfcffc72eaa52f2')
            end
          end

        end
      end
    end
  end
end
