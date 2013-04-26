require "bsf/scraper/version"

module Bsf
  module Scraper

    @@db = nil

    def self.db
      @@db
    end

    def self.db=(db)
      @@db ||= db
    end

  end
end
