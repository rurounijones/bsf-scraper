require 'bsf/scraper/command'

describe Bsf::Scraper::Command do

  describe '.initialize' do

    it { expect { described_class.new }.
         to raise_error(ArgumentError, /0 for 1/) }
    it { expect { described_class.new("test") }.
         to raise_error(ArgumentError, /must be an Array/) }

    describe "argument validation" do

      let(:error_message) {@error_message.string}

      before(:each) do
        @error_message = StringIO.new
        $stderr = @error_message
      end

      after(:all) do
        $stderr = STDERR
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
  end

  def create_class(arguments)
    lambda { described_class.new(arguments)}.should raise_error SystemExit
  end
end
