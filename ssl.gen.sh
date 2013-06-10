#!/bin/bash
#-------------------------------------------------------------------------------
#
# ssl.gen
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The ssl.gen command generates SSL certificate information.

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
usage: ssl.gen  cert_name       | SSL certificate name
--------------------------------------------------------------------------------
                [ -h | --help ] | Show usage information
                ----------------------------------------------------------------
                [ -d | --dir <directory> | Directory to generate certificate files
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
parse_option '-d|--dir' DIRECTORY 'validate_directory' 'Must be a valid directory' || STATUS=2

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

CERT_NAME="${ARGS[0]}"

if [ ! "$CERT_NAME" ]
then
    echo "Certificate name is required to create certificate files"
    echo "$USAGE"
    exit 2
fi

if [ "$DIRECTORY" ]
then
	CERT_NAME="$DIRECTORY/$CERT_NAME"
fi

#-------------------------------------------------------------------------------
# Start

[ $STATUS -eq 0 ] && openssl genrsa -out "${CERT_NAME}.key" 1024 || STATUS=3
[ $STATUS -eq 0 ] && openssl rsa -in "${CERT_NAME}.key" -out "${CERT_NAME}.pem" || STATUS=4
[ $STATUS -eq 0 ] && openssl req -new -key "${CERT_NAME}.pem" -out "${CERT_NAME}.csr" || STATUS=5
[ $STATUS -eq 0 ] && openssl x509 -req -days 365 -in "${CERT_NAME}.csr" -signkey "${CERT_NAME}.pem" -out "${CERT_NAME}.crt" || STATUS=6

exit $STATUS
