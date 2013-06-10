#!/bin/bash
#-------------------------------------------------------------------------------
#
# gem.test
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The gem.test command tests a gem build.

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
usage: gem.test [ -h | --help ]                  | Show usage information
--------------------------------------------------------------------------------
                [ -u | --update <version_type> ] | Either patch, minor, or major
                ----------------------------------------------------------------
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
parse_option '-u|--update' UPDATE_VERSION 'validate_version_update' 'Must be patch, minor, or major' || STATUS=2
parse_option '-d|--dir' DIRECTORY 'validate_gem_project_directory' 'Must be a valid Gem project directory' || STATUS=2

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

# Ensure we are testing valid project directory
if [ "$DIRECTORY" ]
then
	cd "$DIRECTORY"
fi

# Install dependencies
[ $STATUS -eq 0 ] && bundle install || STATUS=3

# Unit testing
[ $STATUS -eq 0 ] && bundle exec rake spec || STATUS=4

# Install new version
if [ "$UPDATE_VERSION" ]
then
    if [ "$UPDATE_VERSION" == 'minor' -o "$UPDATE_VERSION" == 'major' ]
    then
        [ $STATUS -eq 0 ] && git stash clear || STATUS=5
        [ $STATUS -eq 0 ] && git stash save || STATUS=6
        
        version=`cat VERSION`
        releases=(${version//\./ })
        orig_branch="${releases[0]}.${releases[1]}"
        
        case "$UPDATE_VERSION" in
        	major)
                branch="$((${releases[0]} + 1)).0"
        	   ;;
        	minor)
                branch="${releases[0]}.$((${releases[1]} + 1))"
        	   ;;
        esac
        
        if [ -z "`git branch | grep "$branch"`" ]
        then
            [ $STATUS -eq 0 ] && git checkout -b "$branch" "$orig_branch" || STATUS=7	
        else
            [ $STATUS -eq 0 ] && git checkout "$branch" || STATUS=7
        fi
        
        [ $STATUS -eq 0 ] && git stash apply stash@{0} || STATUS=8
        [ $STATUS -eq 0 ] && git stash clear || STATUS=5
    fi
    
    [ $STATUS -eq 0 ] && bundle exec rake version:bump:$UPDATE_VERSION || STATUS=9
fi
[ $STATUS -eq 0 ] && bundle exec rake install || STATUS=10

# Generate Gem information
[ $STATUS -eq 0 ] && bundle exec rake gemspec || STATUS=11

[ $STATUS -eq 0 ] && rm *.gem 2>/dev/null
[ $STATUS -eq 0 ] && gem build *.gemspec || STATUS=12

exit $STATUS
