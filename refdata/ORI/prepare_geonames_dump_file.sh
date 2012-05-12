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
#
DUMP_FROM_GEONAMES_FILENAME=dump_from_geonames.csv

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
# If the Geonames dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${DUMP_FROM_GEONAMES_FILENAME} ]
then
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
SORTED_DUMP_FROM_GEONAMES=sorted_${DUMP_FROM_GEONAMES_FILENAME}
SORTED_CUT_DUMP_FROM_GEONAMES=cut_sorted_${DUMP_FROM_GEONAMES_FILENAME}
#
DUMP_FROM_GEONAMES=${TMP_DIR}${DUMP_FROM_GEONAMES_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Geonames data dump file>]"
	echo "  - Default name for the geo data dump file: '${DUMP_FROM_GEONAMES}'"
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
sed -e "s/^iata\(.\+\)//g" ${DUMP_FROM_GEONAMES} > ${DUMP_FROM_GEONAMES_TMP}
sed -i -e "/^$/d" ${DUMP_FROM_GEONAMES_TMP}

##
# Eliminate the city POR (points of reference) when those duplicate the
# IATA code of the corresponding airport (e.g., SFO, LAX). Note that some
# cities do not duplicate the IATA of their related airports (e.g., PAR, CHI,
# LON).
# a. Replace the 'NULL' fields by 'ZZZZZ', so as to place them at the end
sed -i -e "s/^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^NULL\^\(.\+\)/\1\^ZZZZZ\^\2/g" ${DUMP_FROM_GEONAMES_TMP}
# b. Sort the file by the (IATA, ICAO) code pair
sort -t '^' -k1,1 -k2,2 -k11,11 ${DUMP_FROM_GEONAMES_TMP} > ${SORTED_DUMP_FROM_GEONAMES}
# c. Remove the rows duplicating the IATA code
uniq -w 3 ${SORTED_DUMP_FROM_GEONAMES} > ${DUMP_FROM_GEONAMES_TMP}
\mv -f ${DUMP_FROM_GEONAMES_TMP} ${SORTED_DUMP_FROM_GEONAMES}
# d. Replace back the (remaining) 'ZZZZZ' fields by 'NULL'
sed -i -e "s/^\([A-Z0-9][A-Z0-9][A-Z0-9]\)\^ZZZZZ\^\(.\+\)/\1\^NULL\^\2/g" ${SORTED_DUMP_FROM_GEONAMES}

##
# Only four columns/fields are kept in that version of the file:
# the airport/city (IATA, ICAO) code pair and the geographical coordinates
# (latitude, longitude).
cut -d'^' -f 1,6,7 ${SORTED_DUMP_FROM_GEONAMES} > ${SORTED_CUT_DUMP_FROM_GEONAMES}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${SORTED_DUMP_FROM_GEONAMES}' and '${SORTED_CUT_DUMP_FROM_GEONAMES}' files have been derived from '${DUMP_FROM_GEONAMES}'."
echo

