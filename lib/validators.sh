#!/bin/bash
#
# validators.sh
#
#-------------------------------------------------------------------------------
# Validate a Gem version update type. (Must be non empty.)
#
# USAGE:> validate_version_update $UPDATE_TYPE
#
function validate_version_update()
{
    if [ ! "$1" ] || [ "$1" != 'patch' -a "$1" != 'minor' -a "$1" != 'major' ]
    then
        return 1
    else
        return 0
    fi  
}

#-------------------------------------------------------------------------------
# Validate a Gem project directory. (Must be non empty.)
#
# USAGE:> validate_gem_project_directory $DIR
#
function validate_gem_project_directory()
{
    if validate_directory "$1" && [ -f "$1/Gemfile" ] && [ -f "$1/Rakefile" ]
    then
        return 0
    else
        return 1
    fi  
}

#-------------------------------------------------------------------------------
# Validate a JSON file. (Must be non empty.)
#
# USAGE:> validate_json_file $FILE
#
function validate_json_file()
{
    if validate_file "$1" && [[ $1 =~ \.(json|JSON)$ ]]
    then
        return 0
    else
        return 1
    fi  
}
