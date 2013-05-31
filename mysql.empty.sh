#!/bin/bash

user_name=$1
password=$2
host=$3
database=$4

mysqldump -u${user_name} -p${password} -h ${host} --no-data --add-drop-table ${database} | grep ^DROP | mysql -u${user_name} -p${password} -h ${host} ${database}
