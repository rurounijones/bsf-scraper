require 'mechanize'
require 'ostruct'
require 'bsf/scraper/fund_data_populator/holdings_page_parser'

describe Bsf::Scraper::FundDataPopulator::HoldingsPageParser do

  describe '.initialize' do
    it { expect { described_class.new }.to raise_error(ArgumentError,
                                                       /0 for 3/) }
  end

  describe '#parse' do

    let(:fund) {OpenStruct.new}
    let(:current_fund_price) { 14.00 }

    before(:each) do
      described_class.new(fund, dummy_page, current_fund_price).parse
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

    it 'should set the price' do
      fund.price.should == 14
    end

    it 'should calculate the current price book' do
      fund.pb.should == 2.3125000000000004
    end

    it 'should calculate the current price earnings' do
      fund.pe.should == 18.614583333333336
    end

    it 'should calculate the current price cashflow' do
      fund.pcf.should == 10.177083333333334
    end

    it 'should calculate the current price sales' do
      fund.ps.should == 1.4791666666666667
    end

  end

  def dummy_page
    @dummy_page ||= Mechanize.new.get("file:///#{$spec_home}/fixtures/yahoo_holdings_page.html")
  end

end
