require 'test_helper'

module Pickwick
  module Workers
    module Feeders
      module MPSV
        class ProcessorTest < Test::Unit::TestCase

          context 'MPSV job' do

            setup do
              @processor = Processor.new
              @processor.setup(date: '20131212', type: :incremental)
            end

            should 'generate proper url' do
              Time.stubs(:now).returns(Time.at(1386846348))
              @processor.instance_variable_set("@options", nil)
              @processor.setup

              assert_equal 'http://portal.mpsv.cz/portalssz/download/getfile.do?filename=vmp20131212_xml.zip&_lang=cs_CZ', @processor.__url

              @processor.setup(type: :full)
              assert_equal 'http://portal.mpsv.cz/portalssz/download/getfile.do?filename=vm20131212_xml.zip&_lang=cs_CZ', @processor.__url

              @processor.setup(date: '20131210', type: :full)
              assert_equal 'http://portal.mpsv.cz/portalssz/download/getfile.do?filename=vm20131210_xml.zip&_lang=cs_CZ', @processor.__url
            end

            should "download data archive" do
              VCR.use_cassette('mpsv') do
                assert_nothing_raised do
                  @processor.download_archive
                  assert_equal 330943, @processor.instance_variable_get("@archive").size
                end
              end
            end

            should "extract data archive" do
              VCR.use_cassette('mpsv') do
                assert_nothing_raised do
                  @processor.download_archive
                  @processor.extract_data
                  assert_equal 1726757,@processor.instance_variable_get("@data").size
                end
              end
            end


            should "perform job" do
              Pickwick::API.expects(:store).with do |documents|
                assert_equal 4,  documents.size
                assert_equal 'programátor/ka, analytik/čka',     documents[0][:title]
                assert_equal 'full-time',                        documents[0][:employment_type]
                assert_equal 'asistent/ka pedagoga - ii stupeň', documents[1][:title]
                assert_equal 'part-time',                        documents[1][:employment_type]
              end.returns(mock(status: 200))

              @processor.expects(:download_archive)
              @processor.expects(:extract_data)
              @processor.instance_variable_set('@data', fixture_file('mpsv.xml'))

              @processor.perform
            end

            should "raise error if response from API is not 20x" do
              Pickwick::API.expects(:store).with do |documents|
                assert_equal 4,  documents.size
                assert_equal 'programátor/ka, analytik/čka', documents.first[:title]
              end.returns(stub(status: 404))

              @processor.expects(:download_archive)
              @processor.expects(:extract_data)
              @processor.instance_variable_set('@data', fixture_file('mpsv.xml'))

              assert_raise(Pickwick::API::Error) { @processor.perform }
            end

          end

        end
      end
    end
  end
end
