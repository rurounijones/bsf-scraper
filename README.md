# Bargain Stock Fund's Bloomberg Scraper

[![Build Status](https://secure.travis-ci.org/rurounijones/bsf-scraper.png)](http://travis-ci.org/rurounijones/bsf-scraper)

A command-line script for scraping Bloomberg pages for Fund information and
updating this information in a Database.

This is a rewrite of https://github.com/jhsu802701/bsf-scrape-old in 
idiomatic ruby as an example project for learning purposes.

## Installation

Install this script using rubygems

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

The basic contribution flow is as follows:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
