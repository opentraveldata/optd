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
SQL_FILE_FILENAME=extract_por_with_iata_icao.sql
SQL_FILE=${EXEC_PATH}${SQL_FILE_FILENAME}
# Generated files
DUMP_FILE_FILENAME=por_all_iata_${SNAPSHOT_DATE}.csv
DUMP_FILE_ICAO_ONLY_FILENAME=por_all_icao_only_${SNAPSHOT_DATE}.csv
DUMP_FILE_NO_CODE_FILENAME=por_all_nocode_${SNAPSHOT_DATE}.csv
DUMP_FILE_NO_ICAO_FILENAME=por_all_noicao_${SNAPSHOT_DATE}.csv
DUMP_FILE_DUP_FILENAME=por_all_dup_iata_${SNAPSHOT_DATE}.csv
#
DUMP_FILE=${TMP_DIR}${DUMP_FILE_FILENAME}
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
	echo "      + '${DUMP_FILE}'"
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
#
echo
echo "Exporting points of reference (POR, i.e., airports, cities) data from the tables of Geonames into '${DUMP_FILE}'."
echo "That operation may take several minutes..."
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} > ${DUMP_FILE} < ${SQL_FILE}
echo "... Done"
echo

##
# Remove the first line (header). Note: that step should now be performed by
# the caller.
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

##
# We are now left with only the points of interest containing a non-NULL IATA
# code.

# 3.1. Extract the header into a temporary file
DUMP_FILE_HEADER=${DUMP_FILE}.tmp.hdr
grep "^iata\(.\+\)" ${DUMP_FILE} > ${DUMP_FILE_HEADER}

# 3.2. Remove the header
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_FILE}
sed -i -e "/^$/d" ${DUMP_FILE}

# 4.1. Extract the entries having no ICAO code.
grep "^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^NULL\^\(.\+\)" ${DUMP_FILE} > ${DUMP_FILE_NO_ICAO}

# 4.2. Remove the entries having no ICAO code.
#      Note that there is no ICAO code for a city. Hence, city entries are also
#      filtered out.
#      Note also that, when the same IATA code is used for a city and one of its
#      airports (e.g, AMS, LAX, SFO), two entries with the same IATA code
#      should appear. But, as the city entries are removed in this step, that
#      case of IATA duplicity is avoided/removed.
sed -i -e "s/^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^NULL\^\(.\+\)//g" ${DUMP_FILE}

# 4.3. Spot the (potential) remaining entries having duplicated IATA codes.
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
# 4.3.1. Create the file with no duplicated IATA code.
DUMP_UNIQ_FILE=${DUMP_FILE}.tmp.uniq
DUMP_FILE_TMP=${DUMP_FILE}.tmp
sort -t '^' -k1,1 -k2,2 ${DUMP_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE}
uniq -w 3 ${DUMP_FILE} > ${DUMP_UNIQ_FILE}

# 4.3.2. Create the file with only the duplicated IATA code entries, if any.
DUMP_FILE_DUP_CHECK=${DUMP_FILE_DUP}.tmp.check
comm -23 ${DUMP_FILE} ${DUMP_UNIQ_FILE} > ${DUMP_FILE_DUP_CHECK}
sed -i -e "/^$/d" ${DUMP_FILE_DUP_CHECK}

if [ -s ${DUMP_FILE_DUP_CHECK} ]
then
	POR_DUP_IATA_NB=`wc -l ${DUMP_FILE_DUP_CHECK} | cut -d' ' -f1`
	echo
	echo "!!!!!! WARNING !!!!!!!!"
	echo "Geonames has got ${POR_DUP_IATA_NB} duplicated IATA codes (in addition to those of cities of course). To see them, just do:"
	echo "less ${DUMP_FILE_DUP_CHECK}"
	echo "Note: they result of the comparison between '${DUMP_FILE}' (all POR) and"
	echo "'${DUMP_UNIQ_FILE}' (duplicated POR have been removed)."
	echo "!!!!!! WARNING !!!!!!!!"
	echo
else
	\rm -f ${DUMP_FILE_DUP_CHECK}
fi

# 4.4. Re-add the header
cat ${DUMP_FILE_HEADER} ${DUMP_UNIQ_FILE} > ${DUMP_FILE}
sed -i -e "/^$/d" ${DUMP_FILE}

##
# Clean
if [ "${TMP_DIR}" != "/tmp/por/" ]
then
	\rm -f ${DUMP_FILE_HEADER} ${DUMP_UNIQ_FILE}
fi


# Replace the NULL fields by empty fields
#sed -i -e 's/NULL//g' ${DUMP_FILE}
#sed -i -e 's/NULL//g' ${DUMP_FILE_NO_CODE}

