require 'bsf/scraper/command'

describe Bsf::Scraper::Command do

  describe '.initialize' do
    it { expect { described_class.new }.to raise_error(ArgumentError, /0 for 1/) }
    it { expect { described_class.new("test") }.to raise_error(ArgumentError, /must be a Hash/) }    
  end

end
