require 'bsf/database'

describe Bsf::Database do

  before(:each) do
    in_memory_db = Sequel.sqlite
    Sequel.stub(:connect).and_return(in_memory_db)
  end

  describe '.initialize' do

    it 'connects to the database via socket' do
      described_class.new(options).instance_variable_get(:@connection).class.
        should == Sequel::SQLite::Database
    end

    it 'connects to the database via TCP/IP' do
      described_class.new(options(true)).instance_variable_get(:@connection).class.
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

  def options(host = false)
    hash = { :database_name => 'test', :database_user => 'test',
      :database_password => 'test' }
    hash[:database_host] = '127.0.0.1' if host
    hash
  end

end