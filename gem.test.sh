#!/bin/bash

# Test dependencies
sudo bundle update || exit 1
sudo bundle install || exit 2

# Unit testing
bundle exec rake spec || exit 3

# Install new version
sudo bundle exec rake install || exit 4

# Generate Gem information
bundle exec rake gemspec || exit 5

rm *.gem 2>/dev/null
gem build *.gemspec || exit 6
exit 0
