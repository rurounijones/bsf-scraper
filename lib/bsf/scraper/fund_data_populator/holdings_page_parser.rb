module Bsf
  module Scraper
    class FundDataPopulator

      class HoldingsPageParser

        def initialize(fund, holdings_page)
          @holdings_page = holdings_page
          @fund = fund
        end

        def parse
          @fund.biggest_position = parse_biggest_position
          @fund.original_price = parse_original_price
          @fund.original_price_book = parse_original_price_book
          @fund.original_price_earnings = parse_original_price_earnings
          @fund.original_price_cashflow= parse_original_price_cashflow
          @fund.original_price_sales = parse_original_price_sales
        end

        private

        def parse_original_price
          result = data_tables.search('.time_rtq_ticker/span').text.to_f
          result > 0 ? result : nil
        end

        def parse_original_price_book
          parse_price("Price/Book")
        end

        def parse_original_price_earnings
          parse_price("Price/Earnings")
        end

        def parse_original_price_cashflow
          parse_price("Price/Cashflow")
        end

        def parse_original_price_sales
          parse_price("Price/Sales")
        end

        def parse_biggest_position
          result = data_tables.search('//table[tr[th[contains (text(),' +
                                      '"Top 10 Holdings")]]]/following-' +
                                      'sibling::table[1]/tr/td/table/tr' +
                                      '[2]/td[3]').text.to_f
          result > 0 ? result : nil
        end

        def parse_price(price)
          result = data_tables.search("//tr[td[contains (text(), '#{price}')]]/td[2]").text.to_f
          result > 0 ? result : nil
        end

        # Isolate the part of the page with the actual information we want.
        def data_tables
          @data_tables ||= @holdings_page.search('#rightcol')
        end

      end
    end
  end
end