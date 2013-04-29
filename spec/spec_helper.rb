require 'webmock/rspec'
require 'vcr'
require 'simplecov'
require 'coveralls'

# We are not using VCR right now, it was removed from the only tests it was
# included in. However we may be using it in the future so might as well
# leave it in for the moment
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_responses'
  c.hook_into :webmock
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start