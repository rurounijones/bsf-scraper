require 'mechanize'
require 'ostruct'
require 'bsf/scraper/fund_data_populator/holdings_page_parser'

describe Bsf::Scraper::FundDataPopulator::HoldingsPageParser do

  describe '.initialize' do
    it { expect { described_class.new }.to raise_error(ArgumentError,
                                                       /0 for 2/) }
  end

  describe '#parse' do

    let(:fund) {OpenStruct.new}

    before(:each) do
      described_class.new(fund, dummy_page).parse
    end

    it 'should parse the biggest position' do
      fund.biggest_position.should == 4.14
    end

    it 'should parse the original price' do
      fund.original_price.should == 13.44
    end

    it 'should parse the original price book' do
      fund.original_price_book.should == 2.22
    end

    it 'should parse the original price earnings' do
      fund.original_price_earnings.should == 17.87
    end

    it 'should parse the original price cashflow' do
      fund.original_price_cashflow.should == 9.77
    end

    it 'should parse the original price sales' do
      fund.original_price_sales.should == 1.42
    end

  end

  def dummy_page
    @dummy_page ||= Mechanize.new.get("file:///#{$spec_home}/fixtures/yahoo_holdings_page.html")
  end

end
