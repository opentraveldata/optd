#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from Geonames.
#

displayGeonamesDetails() {
	echo
	echo "The data dump from Geonames can be obtained from this project (OpenTravelData:"
	echo "http://github.com/opentraveldata/optd). For instance:"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/optd.git optdgit"
	echo "cd optdgit/refdata/geonames/data"
	echo "./getDataFromGeonamesWebsite.sh  # it may take several minutes"
	echo "cd por/admin"
	echo "./create_geo_user.sh"
	echo "./create_geo_db.sh"
	echo "./loadGeonamesData.sh"
	echo "./loadGeonamesPorAllByChunks.sh # follow the instructions"
	echo "./loadGeonamesPorAltByChunks.sh # follow the instructions"
	echo "./create_geo_index.sh           # it may take several minutes"
	echo "cd ../../../../tools            # it should be ~/dev/geo/optdgit/refdata/tools"
	echo "./extract_por_with_iata_icao.sh # it may take several minutes"
	echo "It produces a por_all_iata_YYYYMMDD.csv file,"
	echo "which has to be copied as ${TMP_DIR}dump_from_geonames.csv:"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "~/dev/geo/optdgit/refdata/tools/preprepare_geonames_dump_file.sh YYYYMMDD"
	echo "ls -l ${TMP_DIR}"
	echo
}

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
#
DUMP_FILE_FILENAME=dump_from_geonames.csv
#
DUMP_FILE=${TMP_DIR}${DUMP_FILE_FILENAME}

# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`
DUMP_IATA_FILE=${TMP_DIR}por_all_iata_${SNAPSHOT_DATE}.csv
DUMP_NOICAO_FILE=${TMP_DIR}por_all_noicao_${SNAPSHOT_DATE}.csv

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Snapshot date>]"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	echo "    + ${DUMP_IATA_FILE} for the list of IATA codes"
	echo "    + ${DUMP_NOICAO_FILE} for the list of IATA codes without ICAO codes"
	echo "  - Default name for the (output) geo data dump file: '${DUMP_FILE}'"
	echo
	exit -1
fi
#
if [ "$1" = "-g" -o "$1" = "--geonames" ];
then
	displayGeonamesDetails
	exit -1
fi

##
# Data dump file with geographical coordinates
if [ "$1" != "" ];
then
	SNAPSHOT_DATE="$1"
	DUMP_IATA_FILE=${TMP_DIR}por_all_iata_${SNAPSHOT_DATE}.csv
	DUMP_NOICAO_FILE=${TMP_DIR}por_all_noicao_${SNAPSHOT_DATE}.csv
fi

if [ ! -f ${DUMP_IATA_FILE} -o ! -f ${DUMP_NOICAO_FILE} ]
then
	echo "The '${DUMP_IATA_FILE}' and/or '${DUMP_NOICAO_FILE}' files do not exist."
	if [ "$1" = "" ];
	then
		displayGeonamesDetails
	fi
	exit -1
fi

##
# 1.1. Aggregate both dump files
cat ${DUMP_IATA_FILE} ${DUMP_NOICAO_FILE} > ${DUMP_FILE}

##
# 2.1. Extract the header into a temporary file
DUMP_FILE_HEADER=${DUMP_FILE}.tmp.hdr
grep "^alternateName\(.\+\)" ${DUMP_FILE} > ${DUMP_FILE_HEADER}

# 2.2. Remove the header
sed -i -e "s/^alternateName\(.\+\)//g" ${DUMP_FILE}
sed -i -e "/^$/d" ${DUMP_FILE}

##
# 3.1. Replace the 'NULL' fields by 'ZZZZ', so as to place them at the end
sed -i -e "s/^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^NULL\^\(.\+\)/\1\^ZZZZ\^\2/g" ${DUMP_FILE}

##
# 3.2. Sort the Geonames dump file according to the IATA and ICAO codes
DUMP_FILE_TMP=${DUMP_FILE}.tmp
sort -t'^' -k1,1 -k2,2 ${DUMP_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE}

##
# 4.1. Suppress the entries having a duplicated IATA code
uniq -w 3 ${DUMP_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE}

# 5.1. Re-add the header
cat ${DUMP_FILE_HEADER} ${DUMP_FILE} > ${DUMP_FILE_TMP}
sed -i -e "/^$/d" ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE}


##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${DUMP_FILE}' file has been created from the '${DUMP_IATA_FILE}' and '${DUMP_NOICAO_FILE}' files."
echo

