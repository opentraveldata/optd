#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from Geonames.
#

displayGeonamesDetails() {
	echo "The data dump from Geonames can be obtained from the OpenTravelData project"
	echo "(http://github.com/opentraveldata/optd). For instance:"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/optd.git optdgit"
	echo "cd optdgit/refdata/geonames/data"
	echo "./getDataFromGeonamesWebsite.sh  # it may take several minutes"
	echo "cd por/admin"
	echo "./create_geo_user.sh"
	echo "./create_geo_db.sh"
	echo "./loadGeonamesData.sh"
	echo "./loadGeonamesPorAllByChunks.sh  # follow the instructions"
	echo "./loadGeonamesPorAltByChunks.sh  # follow the instructions"
	echo "./create_geo_index.sh  # it may take several minutes"
	echo "./extract_airports.sh  # it may take several minutes"
	echo "It produces a por_air_iata_YYYYMMDD.csv file, which has to be copied as"
	echo "${TMP_DIR}dump_from_geonames.csv:"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "\cp -f ~/dev/geo/optdgit/refdata/geonames/data/por/admin/por_air_iata_YYYYMMDD.csv ${TMP_DIR}dump_from_geonames.csv"
	echo ""
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
DUMP_FROM_GEONAMES_FILENAME=dump_from_geonames.csv
SORTED_DUMP_FROM_GEONAMES=sorted_${DUMP_FROM_GEONAMES_FILENAME}
SORTED_CUT_DUMP_FROM_GEONAMES=cut_sorted_${DUMP_FROM_GEONAMES_FILENAME}
#
DUMP_FROM_GEONAMES=${TMP_DIR}${DUMP_FROM_GEONAMES_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Geonames data dump file>]"
	echo "  - Default name for the geo data dump file: '${GEO_FILE_1}'"
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
	DUMP_FROM_GEONAMES="$1"
	DUMP_FROM_GEONAMES_FILENAME=`basename ${DUMP_FROM_GEONAMES}`
	SORTED_DUMP_FROM_GEONAMES=sorted_${DUMP_FROM_GEONAMES_FILENAME}
	SORTED_CUT_DUMP_FROM_GEONAMES=cut_sorted_${DUMP_FROM_GEONAMES_FILENAME}
	if [ "${DUMP_FROM_GEONAMES}" = "${DUMP_FROM_GEONAMES_FILENAME}" ]
	then
		DUMP_FROM_GEONAMES="${TMP_DIR}${DUMP_FROM_GEONAMES}"
	fi
fi
SORTED_DUMP_FROM_GEONAMES=${TMP_DIR}${SORTED_DUMP_FROM_GEONAMES}
SORTED_CUT_DUMP_FROM_GEONAMES=${TMP_DIR}${SORTED_CUT_DUMP_FROM_GEONAMES}

if [ ! -f "${DUMP_FROM_GEONAMES}" ]
then
	echo "The '${DUMP_FROM_GEONAMES}' file does not exist."
	if [ "$1" = "" ];
	then
		displayGeonamesDetails
	fi
	exit -1
fi


##
# First, remove the header (first line)
DUMP_FROM_GEONAMES_TMP=${DUMP_FROM_GEONAMES}.tmp
sed -e "s/^alternateName\(.\+\)//g" ${DUMP_FROM_GEONAMES} > ${DUMP_FROM_GEONAMES_TMP}
sed -i -e "/^$/d" ${DUMP_FROM_GEONAMES_TMP}


##
# The geonames dump file is sorted according to the code (as is the file of
# best coordinates), just to be sure.
sort -t'^' -k 1,1 ${DUMP_FROM_GEONAMES_TMP} > ${SORTED_DUMP_FROM_GEONAMES}
\rm -f ${DUMP_FROM_GEONAMES_TMP}

##
# Only three columns/fields are kept in that version of the file:
# the airport/city IATA code and the geographical coordinates (latitude,
# longitude).
cut -d'^' -f 1,5,6 ${SORTED_DUMP_FROM_GEONAMES} > ${SORTED_CUT_DUMP_FROM_GEONAMES}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${SORTED_DUMP_FROM_GEONAMES}' and '${SORTED_CUT_DUMP_FROM_GEONAMES}' files have been derived from '${DUMP_FROM_GEONAMES}'."
echo

