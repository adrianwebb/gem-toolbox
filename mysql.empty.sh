#!/bin/bash
#-------------------------------------------------------------------------------
#
# mysql.empty
#
#-------------------------------------------------------------------------------
# Help

if [ -z "$HELP" ]
then
export HELP="
The mysql.empty command deletes all tables in a specified database.

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
usage: mysql.empty  database_name                 | Database name to empty
--------------------------------------------------------------------------------
                   [ -h | --help ]                | Show usage information
                   -------------------------------------------------------------
                   [ -u | --user <user_name> ]    | Database user name 
                                                  | (default: database name)
                   -------------------------------------------------------------
                   [ -p | --password <password> ] | Database user password 
                                                  | (default: database name)
                   -------------------------------------------------------------
                   [ -o | --host <host_name> ]    | Database host name 
                                                  | (default: localhost)
                   -------------------------------------------------------------
                   [ -P | --port <port_num> ]     | Database port number 
                                                  | (default: 3306)
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
DB_HOST='localhost'
DB_PORT=3306

parse_flag '-h|--help' HELP_WANTED
parse_option '-u|--user' DB_USER '' 'Must be a non empty database user' || STATUS=2
parse_option '-p|--password' DB_PASSWORD '' 'Must be a non empty password string' || STATUS=2
parse_option '-o|--host' DB_HOST '' 'Must be a non empty hostname' || STATUS=2
parse_option '-P|--port' DB_PORT '' 'Must be a integer port number' || STATUS=2

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

DATABASE="${ARGS[0]}"

if [ ! "$DATABASE" ]
then
    echo "Database name must be specified"
    echo "$USAGE"
    exit 2
fi

if [ ! "$DB_USER" ]
then
    DB_USER="$DATABASE"
fi

if [ ! "$DB_PASSWORD" ]
then
    DB_PASSWORD="$DATABASE"
fi

#-------------------------------------------------------------------------------
# Start

mysqldump -u"${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_HOST}" -P "${DB_PORT}" --no-data --add-drop-table "${DATABASE}" |\
 grep ^DROP |\
 mysql -u"${DB_USER}" -p"${DB_PASSWORD}" -h "${DB_HOST}" -P "${DB_PORT}" "${DATABASE}"

exit $?
