require 'mechanize'

module Bsf
  module Scraper
    class FundIndexer

      BASE_URL = 'http://www.bloomberg.com/markets/funds/country/usa'

      # Fund names that we want to filter out before saving.All strings in this
      # array must be lowercase only
      NAMES = [ 'bull', 'bear', 'fixed', 'bond', 'real estate', 'ultrasector',
                'sector', 'telecom', 'infrastructure', 'hedge', 'etn',
                'leverage', 'short', 'duration', 'municipal', 'futures',
                'currency', 'mlp', 'premium', 'alternative', 'write', 'inverse',
                'risk-managed', 'treasury', 'treasuries', '3x', '2x',
                'consumer', 'energy', 'financials', 'materials', 'miners',
                'uranium', 'utility']

      # Fund objectives that we want to filter out before saving. All strings
      # in this array must be lowercase only
      OBJECTIVES = [ 'alternative', 'asset-backed securities', 'balanced',
                     'commodity', 'convertible', 'preferred', 'derivative',
                     'alloc', 'debt', 'short', 'government', 'govt', 'futures',
                     'muni', 'real estate', 'mmkt', 'venture capital',
                     'asset backed securities', 'currency', 'market neutral',
                     'flexible portfolio', 'sector']

      def initialize
        @agent = Mechanize.new
      end

      def index
        page = get_page(BASE_URL)
        parse_ticker_data_table(page)
      end

      private

      def get_page(url)
        @agent.get(url)
      end

      def parse_ticker_data_table(page)
        page.search('table.ticker_data tr').each_with_index do |row, index|
          # Due to bad HTML coding on the Bloomberg site they do not use a thead
          # but put their headers in the tbody. Because of this we cannot
          # isolate the data rows using xpath so we just skip the first line
          unless index == 0
            cells = row.search('td')
            attributes = {}
            attributes[:name] = cells[0].text
            attributes[:symbol] = cells[1].text
            attributes[:type] = cells[2].text
            attributes[:objective] = cells[2].text
            filter_funds(attributes)
          end
        end
      end

      def filter_funds(attributes)
        if NAMES.any? {|name| name.match /#{attributes[:name].downcase}/} ||
        OBJECTIVES.any? {|obj| obj.match /#{attributes[:name].downcase}/}
          puts "Filtering out #{attributes[:name]}"
        else
          clean_attributes(attributes)
        end
      end

      def clean_attributes(attributes)
          cleaned_attributes = attributes
          cleaned_attributes[:symbol].sub!(':US','')
          create_fund(cleaned_attributes)
      end

      def create_fund(attributes)
        # Sequel expects the database connection to be setup before the class
        # is defined. Because of that we cannot put the require at the top like
        # usual. We need to define it when we use it
        require 'bsf/fund'
        # TODO: Make this cleaner, we want to create new records when needed
        # but updated existing ones if they differ.
        begin
          Bsf::Fund.new(attributes).save
        rescue
          # No-op
        end
      end

    end
  end
end