require 'trollop'
require 'bsf/scraper/version'

module Bsf
  module Scraper
    class Command

      def initialize(arguments)
        unless arguments.class == Array
          raise ArgumentError, "arguments must be an Array" 
        end
        @options = Trollop::options arguments do
          opt :csv_path, "Full path to output csv file (Required)",
              :type => :string, :short => "-c", :required => true
          opt :database_host,
              "Host IP of the database (Only required if connecting via TCP)",
              :type => :string, :short => "-h"
          opt :database_name, "Database name (Required)", :type => :string,
              :short => "-n", :required => true
          opt :database_user, "Database username (Required)", :type => :string,
              :short => "-u", :required => true
          opt :database_password, "Database password (Required)",
              :type => :string, :short => "-p", :required => true
          version "Bargain Stock Funds Scraper version #{Bsf::Scraper::VERSION}"
        end
      end

    end
  end
end
