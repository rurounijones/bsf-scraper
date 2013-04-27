require 'bsf/scraper/fund_indexer'

describe Bsf::Scraper::FundIndexer do

  before(:each) do
    # TODO: This seriously needs to be refactored out. The DB Connection and
    # creation code needs to be extracted out of the Bsf::Scraper::Command
    # class into a dedicated db management class
    Sequel::Model.db = Sequel.sqlite
    Sequel::Model.db.create_table?(:funds) do
      primary_key :id
      String      :symbol,      :size=>255
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

  describe '.index' do

    it 'Requests fund index pages' do
      VCR.use_cassette('index_requests') do
        described_class.new.index
        WebMock.should
          have_requested(:get,
                         'http://www.bloomberg.com/markets/funds/country/usa')
      end
    end

    # TODO Flesh out this test
    it 'Populates the database with basic fund information' do
      Bsf::Fund.count.should > 0
    end
  end

end