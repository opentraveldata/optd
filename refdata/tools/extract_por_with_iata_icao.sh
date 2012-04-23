#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Database parameters
DB_HOST="localhost"
DB_PORT="3306"

# Database User
DB_USER="geo"

# Database Password
DB_PASSWD="geo"

# Database Name
DB_NAME="geo_geonames"

# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`

##
# Extract airport/city information from the Geonames tables (in particular,
# 'geoname' and 'alternate_name')
SQL_POR_FILENAME=extract_por_with_iata_icao.sql
SQL_CTY_FILENAME=extract_por_cities_with_iata.sql
SQL_POR_FILE=${EXEC_PATH}${SQL_POR_FILENAME}
SQL_CTY_FILE=${EXEC_PATH}${SQL_CTY_FILENAME}
# Generated files
DUMP_FILE_IATA_TVL_FILENAME=por_all_iata_tvl_${SNAPSHOT_DATE}.csv
DUMP_FILE_IATA_CTY_FILENAME=por_all_iata_cty_${SNAPSHOT_DATE}.csv
DUMP_FILE_IATA_ALL_FILENAME=por_all_iata_${SNAPSHOT_DATE}.csv
DUMP_FILE_ICAO_ONLY_FILENAME=por_all_icao_only_${SNAPSHOT_DATE}.csv
DUMP_FILE_NO_CODE_FILENAME=por_all_nocode_${SNAPSHOT_DATE}.csv
DUMP_FILE_NO_ICAO_FILENAME=por_all_noicao_${SNAPSHOT_DATE}.csv
DUMP_FILE_DUP_FILENAME=por_all_dup_iata_${SNAPSHOT_DATE}.csv
#
DUMP_FILE_IATA_TVL=${TMP_DIR}${DUMP_FILE_IATA_TVL_FILENAME}
DUMP_FILE_IATA_CTY=${TMP_DIR}${DUMP_FILE_IATA_CTY_FILENAME}
DUMP_FILE_IATA_ALL=${TMP_DIR}${DUMP_FILE_IATA_ALL_FILENAME}
DUMP_FILE_ICAO_ONLY=${TMP_DIR}${DUMP_FILE_ICAO_ONLY_FILENAME}
DUMP_FILE_NO_CODE=${TMP_DIR}${DUMP_FILE_NO_CODE_FILENAME}
DUMP_FILE_NO_ICAO=${TMP_DIR}${DUMP_FILE_NO_ICAO_FILENAME}
DUMP_FILE_DUP=${TMP_DIR}${DUMP_FILE_DUP_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Database Server Hostname> [<Database Server Port>]]"
	echo "  - Default database server hostname: '${DB_HOST}'"
	echo "  - Default database server port: '${DB_PORT}'"
	echo "  - Database username: '${DB_USER}'"
	echo "  - Database name: '${DB_NAME}'"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	echo "  - Generated (CSV-formatted) data files:"
	echo "      + '${DUMP_FILE_IATA_TVL}'"
	echo "      + '${DUMP_FILE_IATA_CTY}'"
	echo "      + '${DUMP_FILE_ICAO_ONLY}'"
	echo "      + '${DUMP_FILE_NO_CODE}'"
	echo "      + '${DUMP_FILE_NO_ICAO}'"
	echo "      + '${DUMP_FILE_DUP}'"
	echo
	exit -1
fi

##
# Database Server Hostname
if [ "$1" != "" ];
then
	DB_HOST="$1"
fi

# Database Server Port
if [ "$2" != "" ];
then
	DB_PORT="$2"
fi

##
# 0. MySQL dump
# 0.1. Travel-related POR
echo
echo "Exporting points of reference (POR, i.e., airports, railway stations) data from the tables of Geonames into '${DUMP_FILE_IATA_TVL}'."
echo "That operation may take several minutes..."
time mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} > ${DUMP_FILE_IATA_TVL} < ${SQL_POR_FILE}
echo "... Done"
echo
# 0.2. Cities
echo "Exporting populated place (city) data from the tables of Geonames into '${DUMP_FILE_IATA_TVL}'."
echo "That operation may take several minutes..."
time mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} > ${DUMP_FILE_IATA_CTY} < ${SQL_CTY_FILE}
echo "... Done"
echo

##
# Remove the first line (header). Note: that step should now be performed by
# the caller.
#sed -i -e "s/^code\(.\+\)//g" ${DUMP_FILE_IATA_TVL}
#sed -i -e "/^$/d" ${DUMP_FILE_IATA_TVL}

# Replace the tab characters by the '^' separator
sed -i -e 's/\t/\^/g' ${DUMP_FILE_IATA_TVL}
sed -i -e 's/\t/\^/g' ${DUMP_FILE_IATA_CTY}

# 1.1. Extract the rows having no IATA and no ICAO code defined.
#      By construction, cities have a IATA code specified.
grep "^NULL\^NULL\^\(.\+\)" ${DUMP_FILE_IATA_TVL} > ${DUMP_FILE_NO_CODE}

# 1.2. Remove the rows having no IATA and no ICAO code defined
#      By construction, cities have a IATA code specified.
sed -i -e "s/^NULL\^NULL\^\(.\+\)//g" ${DUMP_FILE_IATA_TVL}
sed -i -e "/^$/d" ${DUMP_FILE_IATA_TVL}

# 2.1. Extract the rows having only a ICAO code defined
#      By construction, cities have no ICAO code specified.
grep "^NULL\^\(.\+\)" ${DUMP_FILE_IATA_TVL} > ${DUMP_FILE_ICAO_ONLY}

# 2.2. Remove the rows having only a ICAO code defined
#      By construction, cities have no ICAO code specified.
sed -i -e "s/^NULL\^\(.\+\)//g" ${DUMP_FILE_IATA_TVL}
sed -i -e "/^$/d" ${DUMP_FILE_IATA_TVL}

##
# We are now left with only the points of interest containing a non-NULL IATA
# code.

# 3.1. Extract the headers into temporary files
# 3.1.1. For travel-related POR
DUMP_FILE_TVL_HDR=${DUMP_FILE_IATA_TVL}.tmp.tvlhdr
grep "^iata\(.\+\)" ${DUMP_FILE_IATA_TVL} > ${DUMP_FILE_TVL_HDR}
# 3.1.2. For cities
DUMP_FILE_CTY_HDR=${DUMP_FILE_IATA_CTY}.tmp.ctyhdr
grep "^iata\(.\+\)" ${DUMP_FILE_IATA_CTY} > ${DUMP_FILE_CTY_HDR}
sed -i -e "s/NULL/icao/g" ${DUMP_FILE_CTY_HDR}

# 3.2. Remove the headers
# 3.2.1. For travel-related POR
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_FILE_IATA_TVL}
sed -i -e "/^$/d" ${DUMP_FILE_IATA_TVL}
# 3.2.2. For cities
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_FILE_IATA_CTY}
sed -i -e "/^$/d" ${DUMP_FILE_IATA_CTY}

# 4. Handle ICAO codes for the travel-related POR only. As the cities have no
#    ICAO code, they are not handled here.
# 4.1. Extract the entries having no ICAO code.
grep "^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^NULL\^\(.\+\)" ${DUMP_FILE_IATA_TVL} > ${DUMP_FILE_NO_ICAO}

# 4.2. Remove the travel-related POR entries having no ICAO code.
sed -i -e "s/^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^NULL\^\(.\+\)//g" ${DUMP_FILE_IATA_TVL}
sed -i -e "/^$/d" ${DUMP_FILE_IATA_TVL}

# 4.3. Aggregate the language (e.g., 'en') alternate names on a single line.
#      The alternate names of the same POR, specified as having the same IATA
#      and ICAO codes, as well as the same Geonames ID.
ALT_NAME_AGGREGATOR=${EXEC_PATH}alt_name_aggregator.awk
# 4.3.1. For the travel-related POR
AGG_DUMP_FILE_TMP=${DUMP_FILE_IATA_TVL}.tmp.agg
awk -F'^' -f ${ALT_NAME_AGGREGATOR} ${DUMP_FILE_IATA_TVL} > ${AGG_DUMP_FILE_TMP}
\cp -f ${AGG_DUMP_FILE_TMP} ${DUMP_FILE_IATA_TVL}
# 4.3.2. For the cities
awk -F'^' -f ${ALT_NAME_AGGREGATOR} ${DUMP_FILE_IATA_CTY} > ${AGG_DUMP_FILE_TMP}
\cp -f ${AGG_DUMP_FILE_TMP} ${DUMP_FILE_IATA_CTY}
# 4.3.3. For the travel-related POR having no ICAO code
awk -F'^' -f ${ALT_NAME_AGGREGATOR} ${DUMP_FILE_NO_ICAO} > ${AGG_DUMP_FILE_TMP}
\cp -f ${AGG_DUMP_FILE_TMP} ${DUMP_FILE_NO_ICAO}

# 4.4. Spot the (potential) remaining entries having duplicated IATA codes.
#      Here, only the airport entries having duplicated IATA codes are spotted.
#      That case may typically appear when someone, in Geonames, has mistakenly
#      set the IATA code (say ACQ; that airport is Waseca Municpal Airport and
#      its ICAO code is KACQ) in place of the FAA code (indeed, ACQ is the FAA
#      code, not the IATA code).
#
#      With the uniq command, all the entries having a duplicated IATA code are
#      deleted. Then, the original file (with potential duplicated entries) is
#      compared with the de-duplicated file: the differences are the duplicated
#      entries.
#
# 4.4.1. Create the file with no duplicated IATA code.
DUMP_UNIQ_FILE=${DUMP_FILE_IATA_TVL}.tmp.uniq
DUMP_FILE_TMP=${DUMP_FILE_IATA_TVL}.tmp
sort -t '^' -k1,2 ${DUMP_FILE_IATA_TVL} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE_IATA_TVL}
uniq -w 3 ${DUMP_FILE_IATA_TVL} > ${DUMP_UNIQ_FILE}

# 4.4.2. Create the file with only the duplicated IATA code entries, if any.
DUMP_FILE_DUP_CHECK=${DUMP_FILE_DUP}.tmp.check
comm -23 ${DUMP_FILE_IATA_TVL} ${DUMP_UNIQ_FILE} > ${DUMP_FILE_DUP_CHECK}
sed -i -e "/^$/d" ${DUMP_FILE_DUP_CHECK}

if [ -s ${DUMP_FILE_DUP_CHECK} ]
then
	POR_DUP_IATA_NB=`wc -l ${DUMP_FILE_DUP_CHECK} | cut -d' ' -f1`
	echo
	echo "!!!!!! WARNING !!!!!!!!"
	echo "Geonames has got ${POR_DUP_IATA_NB} duplicated IATA codes (in addition to those of cities of course). To see them, just do:"
	echo "less ${DUMP_FILE_DUP_CHECK}"
	echo "Note: they result of the comparison between '${DUMP_FILE_IATA_TVL}' (all POR) and"
	echo "'${DUMP_UNIQ_FILE}' (duplicated POR have been removed)."
	echo "!!!!!! WARNING !!!!!!!!"
	echo
else
	\rm -f ${DUMP_FILE_DUP_CHECK}
fi

# 4.5. Merge the data files for both POR types (travel-related and cities)
cat ${DUMP_UNIQ_FILE} ${DUMP_FILE_IATA_CTY} > ${DUMP_FILE_IATA_ALL}
sort -t'^' -k1,2 ${DUMP_FILE_IATA_ALL} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE_IATA_ALL}

# 4.6. Re-add the header
cat ${DUMP_FILE_TVL_HDR} ${DUMP_FILE_IATA_ALL} > ${DUMP_FILE_TMP}
sed -e "/^$/d" ${DUMP_FILE_TMP} > ${DUMP_FILE_IATA_ALL}

##
# Clean
if [ "${TMP_DIR}" != "/tmp/por/" ]
then
	\rm -f ${DUMP_FILE_TVL_HDR} ${DUMP_FILE_TMP} ${DUMP_FILE_CTY_HDR}
	\rm -f ${DUMP_UNIQ_FILE} ${DUMP_FILE_IATA_CTY_TMP}
fi


# Replace the NULL fields by empty fields
#sed -i -e 's/NULL//g' ${DUMP_FILE_IATA_TVL}
#sed -i -e 's/NULL//g' ${DUMP_FILE_NO_CODE}

