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
        parse_index_pages
      end

      private

      def parse_index_pages
        # We always get and parse the first page since it has to
        # exist by definition
        @page = @agent.get(BASE_URL)
        parse_ticker_data_table

        # Any future pages on the other hand, may not exist. So we need to
        # process them only if they exist
        while next_page_link
          @page = @agent.click(next_page_link)
          parse_ticker_data_table
        end
      end

      def next_page_link
        @page.search('a.next_page')[0]
      end

      def parse_ticker_data_table
        @page.search('table.ticker_data tr').each_with_index do |row, index|
          # Due to bad HTML coding on the Bloomberg site they do not use a thead
          # but put their headers in the tbody. Because of this we cannot
          # isolate the data rows using xpath so we just skip the first line
          unless index == 0
            cells = row.search('td')
            attributes = {}
            attributes[:name] = cells[0].text
            attributes[:symbol] = cells[1].text
            attributes[:type] = cells[2].text
            attributes[:objective] = cells[3].text
            filter_funds(attributes)
          end
        end
      end

      def filter_funds(attributes)
        unless NAMES.any? {|name| name.match /#{attributes[:name].downcase}/} ||
        OBJECTIVES.any? {|obj| obj.match /#{attributes[:objective].downcase}/}
          clean_attributes(attributes)
        end
      end

      def clean_attributes(attributes)
          cleaned_attributes = attributes
          cleaned_attributes[:symbol].sub!(':US','')
          create_fund(cleaned_attributes)
      end

      def create_fund(attributes)
        fund = Bsf::Fund.where(:symbol => attributes[:symbol]).first
        if fund
          # Sequel is smart and only updates the record if the attributes are
          # actually changed.
          fund.update(attributes)
        else
          Bsf::Fund.new(attributes).save
        end
      end

    end
  end
end