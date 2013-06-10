#!/bin/bash
#-------------------------------------------------------------------------------
#
# gem.patch
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The gem.patch command patches a current minor version of a gem and runs tests 
to prepare for release to RubyGems and the origin repository. 

New version -> major.minor.patch+1

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
usage: gem.patch [ -h | --help ]            | Show usage information
--------------------------------------------------------------------------------
                 [ -r | --release ]         | Release project to RubyGems.org
                 ---------------------------------------------------------------
                 [ -d | --dir <directory> ] | Gem project directory 
                                            | (default: current directory)
"
fi

#-------------------------------------------------------------------------------
# Parameters

SCRIPT_DIR="$(cd "$(dirname "$([ `readlink "$0"` ] && echo "`readlink "$0"`" || echo "$0")")"; pwd -P)"
SHELL_LIB_DIR="$SCRIPT_DIR/lib/shell"

source "$SHELL_LIB_DIR/load.sh" || exit 1

PARAMS=`normalize_params "$@"`

parse_flag '-r|--release' RELEASE_WANTED

#-------------------------------------------------------------------------------
# Start

if [ "$RELEASE_WANTED" ]
then
    "$SCRIPT_DIR"/gem.release.sh --update=patch $@
else
    "$SCRIPT_DIR"/gem.test.sh --update=patch $@
fi
exit "$?"
