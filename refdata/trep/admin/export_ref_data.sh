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

#
function exportAirportCityGeoDetails() {
	TMP_CSV_FILE=${CSV_FILE}.tmp
	echo "Exporting airport & city data into ${CSV_FILE}:"
	mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE} > ${TMP_CSV_FILE}
	cat ${TMP_CSV_FILE} | tr [:upper:] [:lower:] \
| sed -e 's/null//g' | sed -e 's/[:space:]+//g' > ${CSV_FILE}
	rm -f ${TMP_CSV_FILE}
}

# Export the city geographical details
SQL_FILE="./tables/export_ref_place_details.sql"
CSV_FILE="ref_place_details.csv"
#exportAirportCityGeoDetails

# Export the city geographical details
SQL_FILE="./tables/export_ref_place_names.sql"
CSV_FILE="ref_place_names.csv"
exportAirportCityGeoDetails

