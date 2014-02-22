require 'curb'
require 'ams/models'

include AMS::Models

module AMS
  module Grain
    module National

      class Report

        attr_reader :date, :quotes

        def initialize (date, quotes)
          @date = date
          @quotes = quotes
        end

        def market (market_name)
          Report.new(date, @quotes.select{ |q| q.market == market_name })
        end

        def commodity (commodity_name)
          Report.new(date, @quotes.select{ |q| q.commodity == commodity_name })
        end

        def empty?
          @quotes.empty?
        end

        class << self
          def fetch (date, cached=true)
            # Returns: not found, retry required, valid data
            url = "http://search.ams.usda.gov/mndms/#{date.strftime('%Y')}/#{date.strftime('%m')}/NW_GR901#{date.strftime('%Y%m%d')}.TXT"
            file = SourceFile.first(:url => url)
            if !file.nil? and cached == true
              return file
            end

            http = Curl.get(url)
            if http.response_code == 200 and http.body.nil? == false
              created = SourceFile.create(:url => url,
                                          :body => http.body,
                                          :content_type => http.content_type)
              created.save!
              return created
            else
              return nil
            end
          end

          def parse_file (file)
            io_src = file.io
            extra_header = CSV.parse_line(io_src.readline)
            date = Date.strptime(extra_header[2], '%m/%d/%Y')
            records = CSV.new(io_src, :headers => :first_row).to_a
            records.reject! do |r|
              [r["Commodity"].nil?,
               r["Location"].nil?,
               r["Low Price"].nil?,
               r["High Price"].nil?].any?
            end
            quotes = records.map do |r|
              Quote.new(date, r["Commodity"], r["Location"], r["Low Price"], r["High Price"])
            end
            return Report.new(date, quotes)
          end
        end
      end

    end
  end
end

