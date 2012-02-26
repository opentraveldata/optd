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
SQL_FILE="extract_por_with_iata_icao.sql"
DUMP_FILE="por_all_iata_${SNAPSHOT_DATE}.csv"
DUMP_FILE_ICAO_ONLY="por_all_icao_only_${SNAPSHOT_DATE}.csv"
DUMP_FILE_NO_CODE="por_all_nocode_${SNAPSHOT_DATE}.csv"
echo
echo "Exporting points of reference (POR, i.e., airports, cities) data from the tables of Geonames into '${DUMP_FILE}'."
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

# 3.0. We are now left with only the points of interest containing a non-NULL
#      IATA code.

# 3.1. Extract the header into a temporary file
DUMP_FILE_HEADER=${DUMP_FILE}.tmp.hdr
grep "^alternateName\(.\+\)" ${DUMP_FILE} > ${DUMP_FILE_HEADER}

# 3.2. Remove the header
sed -i -e "s/^alternateName\(.\+\)//g" ${DUMP_FILE}
sed -i -e "/^$/d" ${DUMP_FILE}

# 3.3. Remove duplicated entries for IATA codes set for cities (e.g, AMS, LAX).
#      First, the NULL ICAO code is replaced by aaaa, so that it appears on the
#      second line, when the IATA code is duplicated. Hence, with the uniq
#      command, that second line will be deleted.
DUMP_UNIQ_FILE=${DUMP_FILE}.tmp.uniq
sed -i -e "s/\(.\+\)\^NULL\^\(.\+\)/\1\^aaaa\^\2/g" ${DUMP_FILE}
sort -t '^' -k1,1 -k2,2r ${DUMP_FILE} | uniq -w 3 > ${DUMP_UNIQ_FILE}

# 3.4. Re-add the header
cat ${DUMP_FILE_HEADER} ${DUMP_UNIQ_FILE} > ${DUMP_FILE}
sed -i -e "s/\(.\+\)\^aaaa\^\(.\+\)/\1\^NULL\^\2/g" ${DUMP_FILE}
\rm -f ${DUMP_FILE_HEADER} ${DUMP_UNIQ_FILE}


# Replace the NULL fields by empty fields
#sed -i -e 's/NULL//g' ${DUMP_FILE}
#sed -i -e 's/NULL//g' ${DUMP_FILE_NO_CODE}

