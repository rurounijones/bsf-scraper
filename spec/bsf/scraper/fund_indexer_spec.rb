require 'bsf/scraper/fund_indexer'

describe Bsf::Scraper::FundIndexer do

  before(:each) do
    in_memory_db = Sequel.sqlite
    Sequel.stub(:connect).and_return(in_memory_db)
    Sequel::Model.db = Bsf::Database.new({ :database_name => 'test',
                                           :database_user => 'test',
                                           :database_password => 'test' })
    Sequel::Model.db.create_fund_table
  end

  describe '.index' do

    it 'Requests fund index pages' do
      with_vcr do
        described_class.new.index
        WebMock.should
          have_requested(:get,
                         'http://www.bloomberg.com/markets/funds/country/usa')
      end
    end

    # TODO Flesh out this test
    it 'Populates the database with basic fund information' do
      with_vcr do
        described_class.new.index
        Bsf::Fund.count.should > 0
      end
    end
  end

  def with_vcr(&block)
    VCR.use_cassette('index_requests') do
      yield
    end
  end

end