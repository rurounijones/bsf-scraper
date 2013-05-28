require 'trollop'
require 'bsf/scraper'
require 'bsf/database'
require 'bsf/scraper/version'
require 'bsf/scraper/fund_indexer'
require 'bsf/scraper/fund_data_populator'

module Bsf
  module Scraper
    # The main entry point into the application.
    #
    # This class acts as the main entry point into the application. It is called
    # from the minimal ruby file in the bin directory. Since it is the main entry
    # point there are a few obviou things this class should be able to accomplish
    # either by itself or by using other classes.
    #
    # Any command-line application of any complexity will have arguments which 
    # need to be processed.
    #
    # It will also have a 'main' method which will kick off the main processing
    # after the command line arguments have been parsed. 
    #
    # So let us look at this class. It has two public methods, one of which is the
    # constructor. The constructor parses the command-line arguments which seems
    # to make sense. 
    #
    # The {#run} method is the main method which kicks off the main processing. 
    # Again this seems sensible.
    #
    # If we look a little deeper we can see the {#parse_arguments} method. Having
    # this in the {Bsf::Scraper::Command} class means that the it is responsible
    # for parsing arguments. This is not totally bad but if we look a little futher
    # ...
    #
    # The {#run} command actually runs the main part of the application. This means
    # that the {Bsf::Scraper::Command} class is responsible for running the main part
    # of the application.
    #
    # But that means that the {Bsf::Scraper::Command} class has two responsibilities!
    #.
    # SRP (Single Responsibility Principle) says that one class should have one,
    # and only on, responsibility but here we have clearly violated that rule.
    #
    # Is this important? Well if you are dogmatically following the rules then yes,
    # it is important. However you could also reasonably point out that the argument
    # parsing code is not really substantial and it not causing much trouble. 
    #
    # In my opinion you would be right either way. If you want to follow SRP Then
    # we need to get rid of one of the responsibilities. Of the two the easiest one
    # to isolate would be the argument parsing.
    #
    # So one possible refactoring would be to extract the argument parsing into
    # a separate class which is called from here. 'ArgumentParser' perhaps?
    #
    # @todo Extract argument parsing into a separate class (See below)
    class Command

      # A new instance of {Bsf::Scraper::Command}
      #
      # @param [Array] arguments The command-line arguments
      def initialize(arguments)
        parse_arguments(arguments)
      end

      # Run the main application code
      #
      # This method has very little logic. It's purpose is to just be a simple
      # public method which can be called to kick off the main processing.
      #
      # In fact what litle logic it does have should probably be moved into the
      # called method itself to keep things nice and clan here.
      def run
        open_database_connection
        create_fund_table
        index_funds unless @options[:skip_fund_indexing]
        populate_fund_data
      end

      private

      #
      # Parse the command-line arguments
      #
      # Thie method uses the Trollop gem to parse the command-line arguments.
      # It reads the input array and produces a nice, easily navigable hash
      # which we can use to access the options.
      #
      # We then set that options hash into an instance variable called @options
      #
      # As well as that Trollop also provides a few convenience functions for
      # things like the de facto arguments of --help and --version
      #
      # @param [Array] arguments The command-line arguments
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

      # Create a connection to the database
      #
      # Create a connection to the database by passing in the command-line
      # arguments hash. After we have done this then set the {Bsf::Scraper} module's
      # db attribute to be this connection.
      def open_database_connection
        begin
          Bsf::Scraper.db = Bsf::Database.new(@options)
        rescue => e
          $stderr.puts "Database Connection Error: #{e.message}"
          exit(-1)
        end
      end

      # Create the fund table
      #
      # Simply uses the previously created database connection to create the fund
      # table
      #
      # @see Bsf::Database#create_fund_table
      def create_fund_table
        Bsf::Scraper.db.create_fund_table
      end

      # Index the funds
      #
      # Start the fund indexing portion of the application.
      #
      # @see Bsf::Scraper::FundIndexer#index
      def index_funds
        Bsf::Scraper::FundIndexer.new.index
      end

      # Populate the fund data
      #
      # There is something a little strange about this method in that it requires
      # another file INSIDE it? What?!
      #
      # The reason for this is that the #{Bsf::fund} class expects a database
      # connection to have already been established before the class is parsed by
      # ruby. Therefore we can only require this file AFTER the database connection
      # has been created.
      #
      # This method also uses the Sequel gem API to get all the {Bsf::Fund}s. This
      # means that we have tied out #{Bsf::Command} class to the Sequel gem's API.
      # If we change the database gem (To say, for example, ActiveRecord or DataMapper)
      # then there is a danger that we would need to re-write this method.
      #
      # To isolate things properly we should really be calling a method we wrote ourselves
      # on the {Bsf::Fund} class or the {Bsf::Database} class (Both options are viable).
      #
      # @see Bsf::Scraper::FundDataPopulator#populate
      # @todo Get all funds without using Sequel gem's API
      def populate_fund_data
        require 'bsf/fund'
        Bsf::Fund.order(:id).all.each do |fund|
          Bsf::Scraper::FundDataPopulator.new(fund).populate
        end
      end

    end
  end
end
