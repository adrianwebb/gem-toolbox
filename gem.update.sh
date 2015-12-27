#!/bin/bash
#-------------------------------------------------------------------------------
#
# gem.update
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The gem.update command updates a projects gem dependencies.

--------------------------------------------------------------------------------
Tested under Ubuntu 12.04 LTS, 14.04 LTS
Licensed under GPLv3

See the project page at: http://github.com/adrianwebb/gem-toolbox
Report issues here:      http://github.com/adrianwebb/gem-toolbox/issues
"
fi

if [ -z "$USAGE" ]
then
export USAGE="
usage: gem.update [ -h | --help ]            | Show usage information
--------------------------------------------------------------------------------
                  [ -d | --dir <directory> ] | Gem project directory 
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

# Update dependencies
bundle update || exit 3
