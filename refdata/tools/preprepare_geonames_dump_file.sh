#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from Geonames.
#

displayGeonamesDetails() {
	if [ -z "${OPTDDIR}" ]
	then
		export OPTDDIR=~/dev/geo/optdgit/refdata
	fi
	if [ -z "${MYCURDIR}" ]
	then
		export MYCURDIR=`pwd`
	fi
	echo
	echo "The data dump from Geonames can be obtained from the OpenTravelData project"
	echo "(http://github.com/opentraveldata/optd). For instance:"
	echo "MYCURDIR=`pwd`"
	echo "OPTDDIR=${OPTDDIR}"
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
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "${OPTDDIR}/tools/extract_por_with_iata_icao.sh # it may take several minutes"
	echo "It produces both a por_all_iata_YYYYMMDD.csv and a por_all_noicao_YYYYMMDD.csv files,"
	echo "which have to be aggregated into the dump_from_geonames.csv file."
	echo "${OPTDDIR}/tools/preprepare_geonames_dump_file.sh"
	echo "\cp -f ${OPTDDIR}/ORI/best_coordinates_known_so_far.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/ORI/ref_airport_popularity.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/ORI/ori_por_public.csv ${TMP_DIR}ori_airports.csv"
	echo "${OPTDDIR}/tools/update_airports_csv_after_getting_geonames_iata_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo
}

##
# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`
DUMP_IATA_FILENAME=por_all_iata_${SNAPSHOT_DATE}.csv
DUMP_NOICAO_FILENAME=por_all_noicao_${SNAPSHOT_DATE}.csv

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="./"
	TMP_DIR="./"
else
	EXEC_PATH="${EXEC_PATH}/"
	TMP_DIR="${TMP_DIR}/"
fi
#
if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi


##
#
DUMP_FILE_FILENAME=dump_from_geonames.csv
#
DUMP_FILE=${TMP_DIR}${DUMP_FILE_FILENAME}

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
	DUMP_IATA_FILENAME=por_all_iata_${SNAPSHOT_DATE}.csv
	DUMP_NOICAO_FILENAME=por_all_noicao_${SNAPSHOT_DATE}.csv
fi

# If the Geonames dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${DUMP_IATA_FILENAME} ]
then
	TMP_DIR="./"
fi

#
DUMP_IATA_FILE=${TMP_DIR}${DUMP_IATA_FILENAME}
DUMP_NOICAO_FILE=${TMP_DIR}${DUMP_NOICAO_FILENAME}

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
grep "^iata\(.\+\)" ${DUMP_FILE} > ${DUMP_FILE_HEADER}

# 2.2. Remove the header
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_FILE}
sed -i -e "/^$/d" ${DUMP_FILE}

##
# 3.1. Replace the 'NULL' fields by 'ZZZZ', so as to place them at the end
sed -i -e "s/^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^NULL\^\(.\+\)/\1\^ZZZZ\^\2/g" ${DUMP_FILE}

# 3.2. Sort the Geonames dump file according to the (IATA, ICAO) code pair
DUMP_FILE_TMP=${DUMP_FILE}.tmp
sort -t'^' -k1,1 -k2,2 -k11,11 ${DUMP_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE}

# 4.1. Re-add the header
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

