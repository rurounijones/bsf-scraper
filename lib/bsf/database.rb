require 'sequel'

module Bsf

  # This class acts as the gateway to the database. All database related access must be
  # done via an instance of this class. It works by using the Sequel gem to create a
  # connection to the database and forwarding messages to it using 'method_missing'
  # meta-programming.
  #
  # Why wrap the connection instead of just using it directly? Good question. The answer
  # is that we want the rest of the script to know as little about the datastore as
  # possible. By wrapping it inside this class we isolate it from the rest of the script.
  #
  # But do we? As mentioned above we use method_missing meta-programming to forward
  # messages to the Sequel gem. That means that whatever is using this class is using
  # Sequel gem message calls (For example look at the {#populate_fund_data} private method
  # in the # {Bsf::Scraper::Command} class ).
  #
  # For this class to do it's job properly we need to remove the meta-programming and
  # create method calls that can be used by other classes. This way they are using THIS
  # class's API and not the underlying Sequel gem's API.
  #
  # Therefore this class needs some more refactoring. A good example would be a
  # {#get_all_funds} method that could be called by the above mentioned {#populate_fund_data}
  #
  # As well as acting as the gateway this class also includes one utility method to create
  # a table to persist fund data.
  class Database

    # A new instance of {Bsf::Database}
    #
    # If the :database_host option is not set then the script will attempt to
    # connect to a PostgreSQL instance on the local machine.
    #
    # @param [Hash] options
    # @option options String :database_host (nil) The hostname or IP address of the PostgreSQL server
    # @option options String :database_name The name of the database to use
    # @option options String :database_user The PostgreSQL login role to use
    # @option options String :database_password The PostgreSQL login role's password
    def initialize(options)
      connect_to_database(options)
    end

    # Create a PostgreSQL table called 'funds'
    #
    # Using the Sequel gem's migration features we will create a 'funds' table
    # to persist the information we scrape.
    #
    # Note that many of the string fields have a length of 255 characters which is
    # far more than we need. However better safe than sorry. The original script
    # attempted to dynamically resize these fields but this is a case of premature
    # optimization which complicated the code.
    #
    # The table will only hold 20,000 or so rows so we can live with a little wasted
    # space for the simple code benefits it provides us.
    def create_fund_table
      @connection.create_table?(:funds) do
        primary_key :id
        String      :symbol,      :size=>255, :unique => true, :index => true
        String      :name,        :size=>255
        String      :type,        :size=>255
        String      :objective,   :size=>255
        String      :category,    :size=>255
        String      :family,      :size=>255
        String      :style_size,  :size=>6
        String      :style_value, :size=>6
        Float       :price
        Float       :pcf               # price cashflow
        Float       :pb                # price book
        Float       :pe                # price earnings
        Float       :ps                # price sales
        Float       :expense_ratio
        Float       :load_front        # maximum front end sales load
        Float       :load_back         # maximum deferred sales load
        Fixnum      :min_inv           # minimum_initial_investment
        Float       :turnover          # annual holdings turnover
        Float       :biggest_position
        Float       :assets
        DateTime    :created_at
        DateTime    :updated_at
      end
    end

    # Send unknown methods to the underlying Sequel Connection
    #
    # Since the {Bsf::Database} class wraps the Sequel gem's connection to
    # PostgreSQL any method calls which we do not understand are assumed
    # to be Sequel commands.
    #
    # Therefore we will use ruby's 'method missing' meta-programming to catch
    # all of these method calls and then send them to the Sequel connection
    # which was created during initialization.
    #
    # This is a type of 'message forwarding' ( it is also quite often referred
    # to, incorrectly, as 'Delegation'), For more in-depth research please read
    # http://www.saturnflyer.com/blog/jim/2012/07/06/the-gang-of-four-is-wrong-and-you-dont-understand-delegation/
    def method_missing(method, *args, &block)
      @connection.send(method, *args, &block)
    end

    private

    # Create a connection to PostgreSQL using the Sequel Gem
    #
    # We will create the connection hash using a few pre-defined
    # options and getting the rest from the options hash.
    #
    # This connection will be stored in a local variable in the instance of
    # this class. It can then be used to send commands to the database.
    #
    # For more information about connection options please read the Sequel
    # gem's documentation.
    #
    #
    # @param [Hash] options
    # @option options String :database_host (nil) The hostname or IP address of the PostgreSQL server
    # @option options String :database_name The name of the database to use
    # @option options String :database_user The PostgreSQL login role to use
    # @option options String :database_password The PostgreSQL login role's password
    def connect_to_database(options)
      connection_hash = {:adapter => 'postgres',
                          :database => options[:database_name],
                          :user => options[:database_user],
                          :password => options[:database_password],
                          :test => true}

      if options[:database_host]
        connection_hash[:host] = options[:database_host]
      end

      @connection = Sequel.connect(connection_hash)
    end

  end
end