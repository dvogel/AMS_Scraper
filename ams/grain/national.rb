require 'ams/grain/national/report'

# There is no "national" grain price. The national grain report is a set of
# prices from various regional markets.
#
# Source files (CSV format) locations take this form:
# http://search.ams.usda.gov/mndms/2009/01/NW_GR90120090130.TXT
#
# The header of such files looks like this:
# NW_GR901,Daily Grain Review,1/30/2009,,,,,,,,,
# Location,Commodity,Low Price,High Price,Low Price Change,High Price Change,Low Basis,Month,High Basis,Month,Low Basis Change,High Basis Change
#
#
# This module downloads source files and provides access methods that return
# time series iterators.

module AMS
  module Grain
    module National

      def self.time_series (dates, commodity, options = Hash.new)

        quote_series = dates.map do |date|
          file = Report.fetch(date)
          if !file.nil?
            rpt = Report.parse_file(file).commodity(commodity)
            if options[:market]
              rpt = rpt.market(options[:market])
            end

            if !rpt.empty?
              low_sum = 0
              high_sum = 0
              rpt.quotes.each do |q|
                low_sum += q.low
                high_sum += q.high
              end

              Quote.new(date,
                        commodity,
                        options.fetch(:market, '(mean)'),
                        low_sum / rpt.quotes.size,
                        high_sum / rpt.quotes.size)
            end
          end
        end

        quote_series.compact
      end

    end
  end
end

