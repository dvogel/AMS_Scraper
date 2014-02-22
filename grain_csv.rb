require 'bigdecimal/util'
require 'active_support'
require 'ams/grain/national'
require 'trollop'
require_relative 'dmconfig'

opts = Trollop::options do
  opt :from, "First date", :type => :string, :default => '2009-01-01'
  opt :to, "Last date", :type => :string, :default => Date.today.strftime('%Y-%m-%d')
  opt :market, "Market name", :type => :string
  opt :commodity, "Commodity name", :type => :string, :required => true
  opt :outfile, "Output file (- for stdout)", :type => :string, :default => "-"
end

from_date = Date.parse(opts[:from])
to_date = Date.parse(opts[:to])
date_range = from_date.upto(to_date)
quote_series = AMS::Grain::National.time_series(date_range, opts.fetch(:commodity), opts.slice(:market))


outfile = (opts[:outfile] == "-") ? $stdout : File.open(opts[:outfile], 'w')
begin
  output = CSV.new(outfile,
                   :headers => [:date, :market, :commodity, :low_price, :high_price],
                   :write_headers => true)
  quote_series.each do |quote|
    output << [quote.date, quote.market, quote.commodity, quote.low.to_s('F'), quote.high.to_s('F')]
  end
ensure
  outfile.close if !outfile.equal?($stdout)
end

