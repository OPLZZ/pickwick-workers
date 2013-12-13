require 'test_helper'

module Pickwick
  class APITest < Test::Unit::TestCase

    context "When storing" do

      should "get store url" do
        assert_equal "http://localhost:9292/store", Pickwick::API.__store_url
      end

      should "create payload for store call" do
        assert_equal "{\"title\":\"First\"}\n{\"title\":\"Second\"}",
                     Pickwick::API.__store_payload([{title: 'First'}, {title: 'Second'}])
      end

      should "call store endpoint with proper parameters" do
        Faraday.expects(:post).with do |url, params|
          assert_equal "http://localhost:9292/store", url
          assert_equal Pickwick::API.token, params[:token]
          assert_equal "{\"title\":\"Document\",\"id\":123}\n{\"id\":2}\n{\"id\":456,\"title\":\"Another document\"}", params[:payload]
        end.returns(mocked_faraday_response(200, { results: [ {id: 123, version: 2,   status: 200, errors: {}},
                                                       {id: nil, version: nil, status: 400, errors: {title: ["can't be blank"]}},
                                                       {id: 456, version: 1,   status: 201, errors: {}} ]}))

        response = Pickwick::API.store([{title: 'Document', id: 123}, {id: 2}, {id: 456, title: 'Another document'}])
        assert_equal 200, response.status
        assert_equal 200, response.body[:results].first[:status]
      end

    end

  end
end
