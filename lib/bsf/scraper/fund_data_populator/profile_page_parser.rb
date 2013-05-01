module Bsf
  module Scraper
    class FundDataPopulator

      # Responsible for parsing the Yahoo Finance profile page to populate the
      # details regarding each fund.
      #
      # Using the CSS path data in the original script was bringing back no
      # results. I am not sure why and think investigating it will take too much
      # time. Therefore we will use the following method.
      #
      # Because of the unholy mess that is the HTML on the yahoo finance pages
      # we will use nokogiri (via mechanize) to extract the rough portions of
      # the html code with the information we want. We then we will get the
      # exact information we want by regexp'ing that chunk of HTML markup. This
      # may not be the best way but it will suffice for now, can always refactor
      # later
      class ProfilePageParser

        def initialize(fund, profile_page)
          @profile_page = profile_page
          @fund = fund
        end

        def parse
          @fund.category = get_category
          @fund.family = get_family
          @fund.assets = get_assets
          @fund.style_size = get_size
          @fund.style_value = get_value
        end

        private
        # Isolate the 'Fund Overview Table'
        #
        # Isolate the 'Fund Overview Table' as best we can, change it to a string
        # and remove newlines to make it easier to regexp.
        def data_tables
          @data_tables ||= @profile_page.search('table#yfncsumtab').to_s.gsub("\n",'')
        end

        def get_category
         result = confirm_result(
           data_tables.scan(%r{">Category:<\/td><td class=\"yfnc_datamoddata1\">(.*?)<\/td>})
         )
         confirm_result(
           data_tables.scan(%r{">Category:<\/td><td class=\"yfnc_datamoddata1\">.*?>(.*?)<\/a>})
         ) unless result
         result
        end

        def get_family
          confirm_result(
            data_tables.scan(%r{">Fund Family:<\/td><td class=\"yfnc_datamoddata1\">.*?>(.*?)<\/a>})
          )
        end

        def get_assets
          assets = data_tables.scan(%r{">Net Assets:<\/td><td class=\"yfnc_datamoddata1\">(.*?)<\/td>})
          if assets.size == 0
            nil
          else
            assets = assets[0][0]
            if assets.end_with?('B')
              assets[0...-1].to_f * 1_000_000_000
            elsif assets.end_with?('M')
              assets[0...-1].to_f * 1_000_000
            else
              raise StandardError "Unknown assets price suffix"
            end
          end
        end

        def stylebox_value
          @stylebox ||= confirm_result(
                        data_tables.scan(
                          %r{http://us.i1.yimg.com/us.yimg.com/i/fi/3_0stylelargeeq([0-9]).gif}
                        )
                      ).to_i
          @stylebox == 0 ? nil : @stylebox
        end

        def get_size
          return nil unless stylebox_value
          case (stylebox_value / 3)
          when 0..1
            then 'Large'
          when 1..2
            then 'Medium'
          when 2..3
            then 'Small'
          else
            raise StandardError, 'Unknown size'
          end
        end

        def get_value
          return nil if stylebox_value.nil?
          return 'Value' if [1,4,7].include?(stylebox_value)
          return 'Blend' if [2,5,8].include?(stylebox_value)
          return 'Growth' if [3,6,9].include?(stylebox_value)
          raise StandardError, 'Unknown value'
        end

        def confirm_result(result)
          result.size == 0 ? nil : result[0][0]
        end
      end
    end
  end
end