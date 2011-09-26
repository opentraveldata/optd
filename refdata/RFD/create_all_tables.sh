#!/bin/sh
#
# Two parameters are required for this script:
# - the name of "create table file" [create_xxx.sql]
# - the name of data file [xxx.sql]
#
# Two parameters are optional:
# - the username
# - the name of the database
# - the host server of the database
# - the port of the database
#

if [ "$1" = "" -o "$2" = "" -o "$1" = "-h" -o "$1" = "--help" ];
then
	echo "Usage: $0 <Database Username> <Database name> [<Database Server Hostname> [<Database Server Port>]]"
	echo ""
	exit -1
fi

##
# Database Server Hostname
# DB_HOST="localhost"
DB_HOST="ncemysqlp.nce.amadeus.net"
if [ "$5" != "" ];
then
	DB_HOST="$5"
fi

# Database Server Port
# DB_PORT="3306"
DB_PORT="3321"
if [ "$6" != "" ];
then
	DB_PORT="$6"
fi

# Database User
DB_USER="rfd"
if [ "$3" != "" ];
then 
	DB_USER="$3"
fi

# Database Password
DB_PASSWD="${DB_USER}"

# Database Name
DB_NAME="sim_rfd"
if [ "$4" != ""  ]
then 
	DB_NAME="$4"
fi

# Table File Name
SQL_TABLE_FILE="$1"

# Data File Name
SQL_DATA_FILE="$2"

function createTable() {
	TABLES=`grep -i "create table" ${SQL_TABLE_FILE} | cut -d'\`' -f2`
	echo "The ${TABLES} table(s) will be created:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_TABLE_FILE}
	echo "Done"
}

function insertData() {
	TABLES=`grep -i "inserting into" ${SQL_DATA_FILE} | cut -d'\`' -f2`
	echo " Data ${TABLES}:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_DATA_FILE}
	echo "Done"
}

# DDL
#SQL_TABLE_FILE="create_xxx.sql"
createTable
# Data
#SQL_DATA_FILE="xxx.sql"
insertData

