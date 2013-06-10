#!/bin/bash
#-------------------------------------------------------------------------------
#
# gem.major
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The gem.major command updates a gem to the next major version and runs tests 
to prepare for release to RubyGems and the origin repository. 

New version -> major+1.minor.patch

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
usage: gem.major [ -h | --help ]            | Show usage information
--------------------------------------------------------------------------------
                 [ -r | --release ]         | Release project to RubyGems.org
                 ---------------------------------------------------------------
                 [ -d | --dir <directory> ] | Gem project directory 
                                            | (default: current directory)
"
fi

#-------------------------------------------------------------------------------
# Parameters

# Command directory. Can't use get_command_location() yet, as it's not loaded.
SCRIPT_DIR="$(cd "$(dirname "$([ `readlink "$0"` ] && echo "`readlink "$0"`" || echo "$0")")"; pwd -P)"
SHELL_LIB_DIR="$SCRIPT_DIR/lib/shell"

source "$SHELL_LIB_DIR/load.sh" || exit 1

PARAMS=`normalize_params "$@"`

parse_flag '-r|--release' RELEASE_WANTED

#-------------------------------------------------------------------------------
# Start

if [ "$RELEASE_WANTED" ]
then
    "$SCRIPT_DIR"/gem.release.sh --update=major $@
else
    "$SCRIPT_DIR"/gem.test.sh --update=major $@
fi
exit "$?"
