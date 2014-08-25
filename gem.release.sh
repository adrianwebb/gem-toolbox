#!/bin/bash
#-------------------------------------------------------------------------------
#
# gem.release
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The gem.release command installs and releases a gem.

--------------------------------------------------------------------------------
Tested under Ubuntu 12.04 LTS
Licensed under GPLv3

See the project page at: http://github.com/coralnexus/coral-toolbox
Report issues here:      http://github.com/coralnexus/coral-toolbox/issues
"
fi

if [ -z "$USAGE" ]
then
export USAGE="
usage: gem.release [ -h | --help ]                  | Show usage information
--------------------------------------------------------------------------------
                   [ -u | --update <version_type> ] | Either patch, minor, or major
                   -------------------------------------------------------------
                   [ -d | --dir <directory> ]       | Gem project directory 
                                                    | (default: current directory)
"
fi

#-------------------------------------------------------------------------------
# Parameters

STATUS=0
SCRIPT_DIR="$(cd "$(dirname "$([ `readlink "$0"` ] && echo "`readlink "$0"`" || echo "$0")")"; pwd -P)"
SHELL_LIB_DIR="$SCRIPT_DIR/lib/shell"

source "$SHELL_LIB_DIR/load.sh" || exit 1
source "$SCRIPT_DIR/lib/validators.sh" || exit 1

#---

PARAMS=`normalize_params "$@"`

parse_flag '-h|--help' HELP_WANTED
parse_option '-d|--dir' DIRECTORY 'validate_gem_project_directory' 'Must be a valid Gem project directory' || STATUS=2
parse_option '-u|--update' UPDATE_VERSION 'validate_version_update' 'Must be patch, minor, or major' || STATUS=2

# Standard help message.
if [ "$HELP_WANTED" ]
then
    echo "$HELP"
    echo "$USAGE"
    exit 0
fi
if [ $STATUS -ne 0 ]
then
    echo "$USAGE"
    exit $STATUS    
fi

#-------------------------------------------------------------------------------
# Start

# Ensure we are releasing valid project directory
if [ "$DIRECTORY" ]
then
    cd "$DIRECTORY"
fi

# Test Gem
"$SCRIPT_DIR"/gem.test.sh $@ || STATUS="$?"

version=`cat VERSION`
releases=(${version//\./ })
branch="${releases[0]}.${releases[1]}"
tag="v${version}"

[ $STATUS -eq 0 ] && git reset || STATUS=30

# Update gemspec
[ $STATUS -eq 0 ] && git add *.gemspec || STATUS=31
[ $STATUS -eq 0 ] && git commit -m "Updating gemspec file for ${version} release."

# Create version documentation
if [ -d "rdoc/site/${version}" ]
then
  [ $STATUS -eq 0 ] && bundle exec rake rdoc || STATUS=32
  [ $STATUS -eq 0 ] && git add "rdoc/site/${version}" || STATUS=33
  [ $STATUS -eq 0 ] && git add -u "rdoc/site/${version}" || STATUS=33
  [ $STATUS -eq 0 ] && git commit -m "Adding RDoc documentation site for ${version} release."
fi

# Push new release to origin repository
[ $STATUS -eq 0 ] && git tag "$tag" || STATUS=34
[ $STATUS -eq 0 ] && git push --tags origin "$branch" || STATUS=35

# Build a new gem file
[ $STATUS -eq 0 ] && rm *.gem 2>/dev/null
[ $STATUS -eq 0 ] && gem build *.gemspec || STATUS=36

# Publish Gem version
[ $STATUS -eq 0 ] && gem push *.gem || STATUS=37

exit $STATUS
