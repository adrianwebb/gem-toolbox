#!/bin/bash
#-------------------------------------------------------------------------------
#
# user.password
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The user.password command generates a password hash from a plaintext password

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
usage: user.password [ -h | --help ] | Show usage information
--------------------------------------------------------------------------------
"
fi

#-------------------------------------------------------------------------------
# Parameters

STATUS=0
SCRIPT_DIR="$(cd "$(dirname "$([ `readlink "$0"` ] && echo "`readlink "$0"`" || echo "$0")")"; pwd -P)"
SHELL_LIB_DIR="$SCRIPT_DIR/lib/shell"

source "$SHELL_LIB_DIR/load.sh" || exit 1

#---

PARAMS=`normalize_params "$@"`

parse_flag '-h|--help' HELP_WANTED

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

openssl passwd -1 || STATUS=3

exit $STATUS
