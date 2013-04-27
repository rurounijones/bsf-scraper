require 'bsf/database'

describe Bsf::Database do

  before(:each) do
    in_memory_db = Sequel.sqlite
    Sequel.stub(:connect).and_return(in_memory_db)
  end

  describe '.initialize' do

    it 'connects to the database' do
      described_class.new(options).instance_variable_get(:@connection).class.
        should == Sequel::SQLite::Database
    end

    context 'exception handling' do

      before(:each) do
        Sequel.stub(:connect).and_raise StandardError, "Test error"
      end

      it "raises an exception" do
        lambda { described_class.new(options) }.
          should raise_error StandardError, /Test error/
      end

    end

  end

  def options
    { :database_name => 'test', :database_user => 'test',
      :database_password => 'test' }
  end

end