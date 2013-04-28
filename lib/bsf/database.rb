require 'sequel'

module Bsf
  class Database

    def initialize(options)
      connect_to_database(options)
    end

    def create_fund_table
      @connection.create_table?(:funds) do
        primary_key :id
        String      :symbol,      :size=>255, :unique => true, :index => true
        String      :name,        :size=>255
        String      :type,        :size=>255
        String      :objective,   :size=>255
        String      :category,    :size=>6
        String      :family,      :size=>6
        String      :style_size,  :size=>6
        String      :style_value, :size=>6
        Float       :price
        Float       :pcf
        Float       :pb
        Float       :pe
        Float       :ps
        Float       :expense_ratio
        Float       :load_front
        Float       :load_back
        Fixnum      :min_inv
        Float       :turnover
        Float       :biggest_position
        Float       :assets
        DateTime    :created_at
        DateTime    :updated_at
      end
    end

    def method_missing(method, *args, &block)
      @connection.send(method, *args, &block)
    end

    private

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