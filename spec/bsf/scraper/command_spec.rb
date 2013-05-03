require 'bsf/scraper/command'

describe Bsf::Scraper::Command do

  describe '.initialize' do

    let(:error_message) {@error_message.string}

    before(:each) do
      @error_message = StringIO.new
      $stderr = @error_message
    end

    after(:all) do
      $stderr = STDERR
    end

    it { expect { described_class.new }.
         to raise_error(ArgumentError, /0 for 1/) }
    it { expect { described_class.new("test") }.
         to raise_error(ArgumentError, /must be an Array/) }

    context "argument validation" do

      it "accepts a valid set of arguments" do
        lambda { described_class.new(full_valid_arguments)}.
          should_not raise_error SystemExit
      end

      it "validates presence of --csv-path argument" do
        create_class []
        error_message.should match /--csv-path must be specified/
      end

      it "validates presence of --database-name argument" do
        create_class ['--csv-path']
        error_message.should match /--database-name must be specified/
      end

      it "validates presence of --database-user argument" do
        create_class ['--csv-path', '--database-name']
        error_message.should match /--database-user must be specified/
      end

      it "validates presence of --database-password argument" do
        create_class ['--csv-path', '--database-name', '--database-user']
        error_message.should match /--database-password must be specified/
      end

      it "validates presence of --csv-path argument parameter" do
        create_class ['--csv-path', '--database-name', '--database-user',
                      '--database-password']
        error_message.should match /--csv-path' needs a parameter/
      end

      it "validates presence of --database-name argument parameter" do
        create_class ['--csv-path', '/tmp/example.csv', '--database-name',
                      '--database-user', '--database-password']
        error_message.should match /--database-name' needs a parameter/
      end

      it "validates presence of --database-user argument parameter" do
        create_class ['--csv-path', '/tmp/example.csv', '--database-name',
                      'bsf', '--database-user', '--database-password']
        error_message.should match /--database-user' needs a parameter/
      end

      it "validates presence of --database-password argument parameter" do
        create_class ['--csv-path', '/tmp/example.csv', '--database-name',
                      'bsf', '--database-user', 'user', '--database-password']
        error_message.should match /--database-password' needs a parameter/
      end

    end

    describe 'fund indexing' do

      before(:each) do
        Sequel.stub(:connect).and_return(true)
        described_class.any_instance.stub(:create_fund_table)
        described_class.any_instance.stub(:populate_fund_data)
      end

      context 'when enabled' do

        it 'indexes the funds' do
          fund_indexer = double('fund_indexer')
          fund_indexer.stub(:index)
          Bsf::Scraper::FundIndexer.stub(:new).and_return(fund_indexer)
          Bsf::Scraper::FundIndexer.should_receive(:new)
          fund_indexer.should_receive(:index)
          described_class.new(full_valid_arguments).run
        end

      end

      context 'when disabled' do

        it 'does not index the funds' do
          Bsf::Scraper::FundIndexer.should_not_receive(:new)
          described_class.new(full_valid_arguments << '--skip-fund-indexing').run
        end
      end
    end

    describe "database connection" do

      it "sets the Bsf::Scraper module db attribute" do
        Sequel.stub(:connect).and_return(true)
        described_class.any_instance.stub(:create_fund_table)
        described_class.any_instance.stub(:index_funds)
        described_class.new(full_valid_arguments).run
        Bsf::Scraper.db.class.should == Bsf::Database
      end

      context "exception handling" do

        before(:each) do
          Sequel.stub(:connect).and_raise StandardError, "Test error"
        end

        it "raises an error" do
          lambda { described_class.new(full_valid_arguments).run}.
            should raise_error SystemExit
        end

        it "outputs an error message" do
          lambda { described_class.new(full_valid_arguments).run }.should raise_error SystemExit
          error_message.should match /Database Connection Error:/
        end

      end

    end

  end

  def create_class(arguments)
    lambda { described_class.new(arguments)}.should raise_error SystemExit
  end

  def full_valid_arguments
    ['--csv-path', '/tmp/example.csv', '--database-name', 'bsf',
     '--database-user', 'user', '--database-password', 'password']
  end
  
end
