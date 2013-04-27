# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bsf/scraper/version'

Gem::Specification.new do |spec|
  spec.name          = 'bsf-scraper'
  spec.version       = Bsf::Scraper::VERSION
  spec.authors       = ['Jeffrey Jones']
  spec.email         = ['jeff@jones.be']
  spec.description   = %q{A command-line script for scraping Bloomberg pages
                          for fund information for the Bargain Stock Funds
                          website}
  spec.summary       = %q{A command-line script for scraping bloomberg pages 
                          for fund information}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~>2.13'
  spec.add_development_dependency 'webmock', '~>1.9.0' # VCR limited to 1.9
  spec.add_development_dependency 'vcr', '~>2.4.0'
  spec.add_development_dependency 'sqlite3'

  spec.add_dependency 'trollop', '~> 2.0'
  spec.add_dependency 'sequel'
  spec.add_dependency 'sequel_pg'
  spec.add_dependency 'mechanize'
end
