#!/bin/sh
#
# One parameter is required for this script:
# - the username
#
# Three parameters are optional:
# - the database name
# - the host server of the database
# - the port of the database
#

if [ "$1" = "-h" -o "$1" = "--h" -o "$1" = "--help" ];
then
	echo "Usage: $0 [<Database Username> [<Database Name> [<Database Server Hostname> [<Database Server Port>]]]]"
	echo ""
	echo "Default values:"
	echo "<Database Username> = geo"
	echo "<Database Name> = geo_geonames"
	echo "<Database Server Hostname> = localhost"
	echo "<Database Server Port> = 3306"
	echo ""
	exit -1
fi

##
# Database Server Hostname
# Database User
DB_USER="geo"
if [ "$1" != "" ];
then
	DB_USER="$1"
fi

# Database Password
DB_PASSWD="${DB_USER}"

# Database Name
DB_NAME="${DB_USER}_geonames"
if [ "$2" != "" ];
then
	DB_NAME="$2"
fi

DB_HOST="localhost"
if [ "$3" != "" ];
then
	DB_HOST="$3"
fi

# Database Server Port
DB_PORT="3306"
if [ "$4" != "" ];
then
	DB_PORT="$4"
fi

##
# Drop a table
dropTable() {
	echo "The ${TABLE} table will be dropped:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "drop table ${DB_NAME}.${TABLE}"
}

# Table: drop the ref_place_details table
TABLE=ref_place_details
dropTable

# Table: drop the ref_place_names table
TABLE=ref_place_names
dropTable

# Table: drop the airport_popularity table
TABLE=airport_popularity
dropTable
