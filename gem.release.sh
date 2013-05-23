#!/bin/bash

# Test Gem
gem.test || exit "$?"

# Install new version
bundle exec rake version:bump:$1 || exit 10
bundle exec rake install || exit 11

version=`cat VERSION`
releases=(${version//\./ })
branch="${releases[0]}.${releases[1]}"
tag="${version}"

# Generate Gem information
bundle exec rake gemspec || exit 12

git add *.gemspec || exit 13
git commit -m "Updating gemspec file for ${version} release." || exit 14

# Push new release to origin repository
git tag "$tag" || exit 15
git push --tags origin "$branch" || exit 16

# Build a new gem file
rm *.gem 2>/dev/null
gem build *.gemspec || exit 17

# Publish Gem version
gem push *.gem || exit 18
exit 0
