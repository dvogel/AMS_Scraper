require 'bigdecimal'
require 'rubygems'
require 'data_mapper'

module AMS
  module Models

    class SourceFile
      include DataMapper::Resource

      property :url, String, :unique_index => :uniq, :required => true, :key => true
      property :body, String
      property :content_type, String

      def io
        StringIO.new(self.body)
      end
    end

    class Quote
      attr_reader :date, :commodity, :market, :low, :high

      def initialize (date, commodity, market, low_price, high_price)
        @date = date
        @commodity = commodity
        @market = market
        @low = low_price.to_d
        @high = high_price.to_d
      end
    end
  end
end

