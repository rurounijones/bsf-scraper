require 'trollop'
require 'bsf/scraper'
require 'bsf/database'
require 'bsf/scraper/version'
require 'bsf/scraper/fund_indexer'
require 'bsf/scraper/fund_data_populator'

module Bsf
  module Scraper
    class Command

      def initialize(arguments)
        parse_arguments(arguments)
      end

      def run
        open_database_connection
        create_fund_table
        index_funds unless @options[:skip_fund_indexing]
        populate_fund_data
      end

      private

      def parse_arguments(arguments)
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
          opt :skip_fund_indexing, "Skip fund indexing from Bloomberg site"
          version "Bargain Stock Funds Scraper version #{Bsf::Scraper::VERSION}"
        end
      end

      def open_database_connection
        begin
          Bsf::Scraper.db = Bsf::Database.new(@options)
        rescue => e
          $stderr.puts "Database Connection Error: #{e.message}"
          exit(-1)
        end
      end

      def create_fund_table
        Bsf::Scraper.db.create_fund_table
      end

      def index_funds
        Bsf::Scraper::FundIndexer.new.index
      end

      def populate_fund_data
        require 'bsf/fund'
        Bsf::Fund.order(:id).all.each do |fund|
          Bsf::Scraper::FundDataPopulator.new(fund).populate
        end
      end

    end
  end
end
