require 'sequel'

module Bsf
  class Fund < Sequel::Model
    self.plugin :timestamps, :update_on_create=>true

    attr_accessor :original_price, :original_price_book,
                  :original_price_earnings, :original_price_cashflow,
                  :original_price_sales
  end
end