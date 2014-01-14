module Pickwick
  module Workers
    module Feeders
      module MPSV
        class Processor
          include Sidekiq::Worker

          class DownloadFailed   < Exception; end
          class DataFileNotFound < Exception; end

          def perform(options={})
            setup(options)
            download_archive
            extract_data
            set_parser

            process_data
          ensure
            @archive.close  rescue nil
            @archive.unlink rescue nil
          end

          def setup(options={})
            options.symbolize_keys!
            @options               = options
            @options[:type]      ||= :incremental
            @options[:date]      ||= Time.now.strftime("%Y%m%d")
            @options[:bulk_size] ||= 1000
            @archive               = Tempfile.new("#{@options[:type]}-#{@options[:date]}")
          end

          def download_archive
            response = Faraday.get(__url)
            raise DownloadFailed unless response.success?
            @archive.write(response.body)
            @archive.rewind
          end

          def extract_data
            archive   = Zip::File.open(@archive.path)
            data_file = archive.find { |f| f.name == __data_file_name }
            raise DataFileNotFound unless data_file
            @data     = data_file.get_input_stream.read
          end

          def set_parser
            @parser = Parser.new(data: @data, bulk_size: @options[:bulk_size])
          end

          def process_data
            @parser.fetch do |documents|
              response = Pickwick::API.store(documents)
              raise Pickwick::API::Error, "Status code: #{response.status}" if response.status > 201
            end
          end

          def __data_file_name
            "vm#{"p" if @options[:type] == :incremental}#{@options[:date]}.xml"
          end

          def __url
            "http://portal.mpsv.cz/portalssz/download/getfile.do?filename=vm#{"p" if @options[:type] == :incremental}#{@options[:date]}_xml.zip&_lang=cs_CZ"
          end

        end
      end
    end
  end
end
