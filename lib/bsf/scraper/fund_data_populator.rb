require 'mechanize'
require 'bsf/scraper/fund_data_populator/profile_page_parser'
require 'bsf/scraper/fund_data_populator/holdings_page_parser'
require 'benchmark'
module Bsf
  module Scraper

    class FundDataPopulator

      PROFILE_URL = 'http://finance.yahoo.com/q/pr?s='
      HOLDINGS_URL = 'http://finance.yahoo.com/q/hl?s='
      PRICE_URL = 'http://download.finance.yahoo.com/d/quotes.csv?s='

      def initialize(fund)
        puts "Populating #{fund.id} - #{fund.name}" unless $spec_home
        @fund = fund
        @agent = Mechanize.new
      end

      def populate
        ProfilePageParser.new(@fund, profile_page).parse
        HoldingsPageParser.new(@fund, holdings_page, fund_price).parse
        @fund.save
      end

      private

      def profile_page
        @agent.get("#{PROFILE_URL}#{@fund.symbol}")
      end

      def holdings_page
        @agent.get("#{HOLDINGS_URL}#{@fund.symbol}")
      end

      def fund_price
        @agent.get("#{PRICE_URL}#{@fund.symbol}&f=l1").body.to_f
      end

    end
  end
end