#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo "Usage: $0 [<Database Server Hostname> [<Database Server Port>]]"
	echo ""
	exit -1
fi

##
# Database Server Hostname
DB_HOST="localhost"
if [ "$1" != "" ];
then
	DB_HOST="$1"
fi

# Database Server Port
DB_PORT="3306"
if [ "$2" != "" ];
then
	DB_PORT="$2"
fi

# Database User
DB_USER="geo"

# Database Password
DB_PASSWD="geo"

# Database Name
DB_NAME="geo_geonames"

# Create the tables
SQL_FILE="create_table_geonames.sql"
echo "Creating the tables for Geonames:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}

# Load the data into the tables
SQL_FILE="fill_table_geonames.sql"
echo "Load data into the tables of Geonames:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}
