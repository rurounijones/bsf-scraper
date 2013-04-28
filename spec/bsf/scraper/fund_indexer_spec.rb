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

    context 'page fetching' do

      it 'Requests first fund index page' do
        klass = described_class.new
        klass.stub(:parse_ticker_data_table)
        klass.stub(:next_page_link)
        WebMock.should
          have_requested(:get,
                          'http://www.bloomberg.com/markets/funds/country/usa')
      end

      it 'requests subsequent fund index page' do
        pending 'Need to modify sample pages'
      end
    end

    context 'database population' do

      # To perform the following tests quickly we need to create a page
      # with sample fund data which will trigger the name and objective filters.
      # This is a hassle which I cannot be bothered to do at the moment.

      # The fact that we want to test these methods but that they are totally
      # private is a good indication that we want to extract them out of the
      # FundIndexer class
      context 'fund filtering' do
        it 'filters out funds with unwanted names' do
          pending 'Need to modify sample page with test data'
        end

        it 'filters out funds with unwanted objectives' do
          pending 'Need to modify sample page with test data'
        end
      end

      context 'record creation' do

        it 'creates new records'
        it 'updates existing records'

      end
    end
  end

end