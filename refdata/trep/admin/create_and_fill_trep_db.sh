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

# Database Server Hostname
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
# Check file existence
checkSQLFile() {
	if [ ! -r ${SQL_FILE} ]; then
		echo
		echo "The ${SQL_FILE} SQL file can not be found"
		echo
		exit -1;
	fi
}

# Create the database
createDatabase() {
	checkSQLFile
	echo "The '${DB_NAME}' database will be created:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} mysql -e "create database if not exists ${DB_NAME} default character set utf8 collate utf8_unicode_ci;"
	echo "The '${DB_NAME}' database has been created."
}

# Scan a SQL script for the names of (database) tables
createTable() {
	checkSQLFile
	echo "The ${SQL_FILE} table(s) will be created:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}
	echo "The ref_place_details and ref_place_names tables have been created."
}

#
loadData() {
	SQL_FILE=${SQL_LOADER_FILE}
	checkSQLFile
	echo "The ${SQL_LOADER_FILE} table(s) will be filled from *.csv files:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_LOADER_FILE}
	echo "Done"
}

#
trimStateCode() {
	echo "Triming the spaces from the state_code field of the ${TABLE} table:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "update ${TABLE} set city_code=NULL where city_code='';"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "update ${TABLE} set state_code=NULL where state_code like '%null%';"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "update ${TABLE} set state_code=NULL where length(state_code)=2;"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "update ${TABLE} set state_code=substring(state_code,2,2) where length(state_code)=4;"
	echo "Done"
}

#
countRows() {
	echo "Counting the rows from the ${TABLE} table:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "select count(*) from ${TABLE};"
}

# Database
SQL_FILE="create_geo_geonames_db.sql"
createDatabase

# Table: Airport and City
SQL_FILE="create_table_places.sql"
createTable

# Load data into the table
SQL_LOADER_FILE="fill_table_places.sql"
loadData

# Create the tables
SQL_FILE="create_table_airport_popularity.sql"
createTable

# Load the data into the tables
SQL_LOADER_FILE="fill_table_airport_popularity.sql"
loadData

# Trim the spaces from the state_code field of the ref_place_details table
TABLE=ref_place_details
trimStateCode

# Count the rows from the ref_place_details table
TABLE=ref_place_details
countRows

# Count the rows from the ref_place_names table
TABLE=ref_place_names
countRows

# Count the rows from the airport_popularity table
TABLE=airport_popularity
countRows
