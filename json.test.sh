#!/bin/bash
#-------------------------------------------------------------------------------
#
# json.test
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The json.test command checks the validity of a given JSON file.

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
usage: json.test file_path       | JSON file path to test
--------------------------------------------------------------------------------
                 [ -h | --help ] | Show usage information
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

ARGS=`get_args "$PARAMS"`

FILE_PATH="${ARGS[0]}"

if ! validate_json_file "$FILE_PATH"
then
	echo "Invalid JSON file path given"
	echo "$USAGE"
	exit 2
fi

#-------------------------------------------------------------------------------
# Start

python -m json.tool "$FILE_PATH" 1> /dev/null
if [ $? -eq 0 ]; then
    echo "Success!"
else
    echo "Failed"
    STATUS=3
fi
exit $STATUS