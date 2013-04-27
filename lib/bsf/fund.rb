require 'sequel'

module Bsf
  class Fund < Sequel::Model
    self.plugin :timestamps, :update_on_create=>true
  end
end