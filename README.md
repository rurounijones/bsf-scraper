# Bargain Stock Fund's Bloomberg Scraper

[![Build Status](https://secure.travis-ci.org/rurounijones/bsf-scraper.png)](http://travis-ci.org/rurounijones/bsf-scraper)
[![Coverage Status](https://coveralls.io/repos/rurounijones/bsf-scraper/badge.png?branch=master)](https://coveralls.io/r/rurounijones/bsf-scraper)
[![Code Climate](https://codeclimate.com/github/rurounijones/bsf-scraper.png)](https://codeclimate.com/github/rurounijones/bsf-scraper)
[![Dependency Status](https://gemnasium.com/rurounijones/bsf-scraper.png)](https://gemnasium.com/rurounijones/bsf-scraper)

A command-line script for scraping Bloomberg and Yahoo Finance pages for fund
information and updating this information in a PostgreSQL database.

This is a rewrite of https://github.com/jhsu802701/bsf-scrape-old in 
idiomatic ruby as an example project for practice and teaching purposes.

## Installation

### Dependencies

The gem expects that a PostgreSQL database is installed on your 
system. The script will attempt to create a table (funds) in the 
database if it does not yet exist so your PostgreSQL user will 
require the relevant permissions.

This gem has been tested on ruby 1.9.3 and 2.0.0. It will NOT
work on jruby as the database dependencies need to be adapted.

### From Github

Clone this repository into the directory of your choosing.

Then cd to that directory (this script has rvm/rbenv config files 
which will trigger if you have either of them installed) then run 
bundle install to install the supporting gems. 

### From Rubygems

Note that this option does not work yet as a gem version has not been
pushed to rubygems. Please use the "From github" method.

Install this script from rubygems using the gem command

    $ gem install bsf-scraper

## Usage

Run this script from the command-line using the following command

    bsf-scraper

For information regarding command-line options please run

    bsf-scraper --help

## Contributing

This script comes with an rspec test suite. Any contributions should be tested.

You can run the tests with either:

    rake spec

or

    rake

Code coverage information is created when running the tests. This information 
can be found in the 'coverage' directory which will be created after the
first test. Subsequent tests will update this directory.

The basic contribution flow is as follows:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
