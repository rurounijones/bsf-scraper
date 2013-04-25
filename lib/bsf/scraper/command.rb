module Bsf
  module Scraper
    class Command
      
      def initialize(options)
        raise ArgumentError, "options must be a Hash" unless options.class == Hash
      end
     
    end
  end
end
