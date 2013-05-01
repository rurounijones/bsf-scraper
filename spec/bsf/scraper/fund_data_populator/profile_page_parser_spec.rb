require 'mechanize'
require 'ostruct'
require 'bsf/scraper/fund_data_populator/profile_page_parser'

describe Bsf::Scraper::FundDataPopulator::ProfilePageParser do

  describe '.initialize' do
    it { expect { described_class.new }.to raise_error(ArgumentError,
                                                       /0 for 2/) }
  end

  describe '#parse' do

    let(:fund) {OpenStruct.new}

    before(:each) do
      described_class.new(fund, dummy_page).parse
    end

    it 'should parse the category' do
      fund.category.should == 'Mid-Cap Blend'
    end

    it 'should parse the family' do
      fund.family.should == '13D Management'
    end

    it 'should parse the assets' do
      fund.assets.should == 15_490_000
    end

    it 'should parse the size' do
      fund.style_size.should == 'Medium'
    end

    it 'should parse the value' do
      fund.style_value.should == 'Growth'
    end

    it 'should parse the minimum initial investment' do
      fund.min_inv.should == 2500
    end

    it 'should parse the annual holdings turnover' do
      fund.turnover.should == 45.5
    end

    it 'should parse the expense ratio' do
      fund.expense_ratio.should == 1.75
    end

    it 'should parse the max front end sales load' do
      fund.load_front.should == 5.75
    end

    it 'should parse the max deferred sales Load' do
      fund.load_back.should == 2.1
    end

  end

  def dummy_page
    @dummy_page ||= Mechanize.new.get("file:///#{$spec_home}/fixtures/yahoo_profile_page.html")
  end

end
