#!/bin/bash

# Test dependencies
bundle install || exit 1

# Unit testing
bundle exec rake spec || exit 2

# Install new version
bundle exec rake install || exit 3

# Generate Gem information
bundle exec rake gemspec || exit 4

rm *.gem 2>/dev/null
gem build *.gemspec || exit 5
