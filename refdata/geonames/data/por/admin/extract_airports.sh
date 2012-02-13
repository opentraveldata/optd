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

# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`

# Extract airport/city information from the Geonames tables (in particular,
# geoname and alternate_name)
SQL_FILE="extract_airports.sql"
DUMP_FILE="por_air_iata_${SNAPSHOT_DATE}.csv"
DUMP_FILE_ICAO_ONLY="por_air_icao_only_${SNAPSHOT_DATE}.csv"
DUMP_FILE_NO_CODE="por_air_nocode_${SNAPSHOT_DATE}.csv"
echo
echo "Exporting airport/airbase/heliport data from the tables of Geonames into '${DUMP_FILE}'."
echo "That operation may take several minutes..."
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} > ${DUMP_FILE} < ${SQL_FILE}
echo "... Done"
echo

# Remove the first line (header)
#sed -i -e "s/^code\(.\+\)//g" ${DUMP_FILE}
#sed -i -e "/^$/d" ${DUMP_FILE}

# Replace the tab characters by the '^' separator
sed -i -e 's/\t/\^/g' ${DUMP_FILE}

# 1.1. Extract the rows having no IATA and no ICAO code defined
grep "^NULL\^NULL\^\(.\+\)" ${DUMP_FILE} > ${DUMP_FILE_NO_CODE}

# 1.2. Remove the rows having no IATA and no ICAO code defined
sed -i -e "s/^NULL\^NULL\^\(.\+\)//g" ${DUMP_FILE}
sed -i -e "/^$/d" ${DUMP_FILE}

# 2.1. Extract the rows having only a ICAO code defined
grep "^NULL\^\(.\+\)" ${DUMP_FILE} > ${DUMP_FILE_ICAO_ONLY}

# 2.2. Remove the rows having only a ICAO code defined
sed -i -e "s/^NULL\^\(.\+\)//g" ${DUMP_FILE}
sed -i -e "/^$/d" ${DUMP_FILE}

# Replace the NULL fields by empty fields
#sed -i -e 's/NULL//g' ${DUMP_FILE}
#sed -i -e 's/NULL//g' ${DUMP_FILE_NO_CODE}

