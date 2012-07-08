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
# Input file names
GEO_RAW_FILENAME=dump_from_geonames.csv
GEO_ORI_FILENAME=best_coordinates_known_so_far.csv

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
# Trick to get the actual full-path
EXEC_FULL_PATH=`pushd ${EXEC_PATH}`
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | cut -d' ' -f1`
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | sed -e 's|~|'${HOME}'|'`
#
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
# If the Geonames dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${GEO_RAW_FILENAME} ]
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
# Sanity check: that (executable) script should be located in the tools/ sub-directory
# of the OpenTravelData project Git clone
EXEC_DIR_NAME=`basename ${EXEC_FULL_PATH}`
if [ "${EXEC_DIR_NAME}" != "tools" ]
then
	echo
	echo "[$0] Inconsistency error: this script ($0) should be located in the refdata/tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
	echo
	exit -1
fi

##
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# ORI sub-directory
ORI_DIR=${OPTD_DIR}ORI/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Log level
LOG_LEVEL=4

##
# Input files
GEO_RAW_FILE=${TOOLS_DIR}${GEO_RAW_FILENAME}
GEO_ORI_FILE=${ORI_DIR}${GEO_ORI_FILENAME}

##
# Output (generated) files
GEO_WPK_FILENAME=wpk_${GEO_RAW_FILENAME}
SORTED_GEO_WPK_FILENAME=sorted_${GEO_WPK_FILENAME}
SORTED_CUT_GEO_WPK_FILENAME=cut_sorted_${GEO_WPK_FILENAME}
#
GEO_WPK_FILE=${TMP_DIR}${GEO_WPK_FILENAME}
SORTED_GEO_WPK_FILE=${TMP_DIR}${SORTED_GEO_WPK_FILENAME}
SORTED_CUT_GEO_WPK_FILE=${TMP_DIR}${SORTED_CUT_GEO_WPK_FILENAME}
#

##
# Cleaning
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${SORTED_GEO_WPK_FILE} ${SORTED_CUT_GEO_WPK_FILE}
		#\rm -f ${GEO_WPK_FILE}
	fi
	exit
fi

##
# Usage
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<refdata directory of the OpenTravelData project Git clone> [<log level>]]"
	echo "  - Default refdata directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
	echo "  - Default path for the Geonames data dump file: '${GEO_RAW_FILE}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - ORI-maintained list of POR (points of reference): '${GEO_ORI_FILE}'"
	echo "  - Generated files:"
	echo "    + '${GEO_WPK_FILE}'"
	echo "    + '${SORTED_GEO_WPK_FILE}'"
	echo "    + '${SORTED_CUT_GEO_WPK_FILE}'"
	echo
	exit
fi
#
if [ "$1" = "-g" -o "$1" = "--geonames" ]
then
	displayGeonamesDetails
	exit
fi

##
# The OpenTravelData refdata/ sub-directory contains, among other things,
# the Geonames data dump.
if [ "$1" != "" ]
then
	if [ ! -d $1 ]
	then
		echo
		echo "[$0] The first parameter ('$1') should point to the refdata/ sub-directory of the OpenTravelData project Git clone. It is not accessible here."
		echo
		exit -1
	fi
	OPTD_DIR_DIR=`dirname $1`
	OPTD_DIR_BASE=`basename $1`
	OPTD_DIR="${OPTD_DIR_DIR}/${OPTD_DIR_BASE}/"
	ORI_DIR=${OPTD_DIR}ORI/
	TOOLS_DIR=${OPTD_DIR}tools/
	GEO_RAW_FILE=${TOOLS_DIR}${GEO_RAW_FILENAME}
	GEO_ORI_FILE=${ORI_DIR}${GEO_ORI_FILENAME}
fi

if [ ! -f "${GEO_RAW_FILE}" ]
then
	echo
	echo "[$0] The '${GEO_RAW_FILE}' file does not exist."
	echo
	if [ "$1" = "" ];
	then
		displayGeonamesDetails
	fi
	exit -1
fi

##
# Log level
if [ "$2" != "" ]
then
	LOG_LEVEL="$2"
fi

##
# Generate a second version of the file with the ORI primary key (integrating
# the location type)
ORI_PK_ADDER=${TOOLS_DIR}geo_pk_creator.awk
awk -F'^' -v log_level=${LOG_LEVEL} -f ${ORI_PK_ADDER} ${GEO_ORI_FILE} ${GEO_RAW_FILE} > ${GEO_WPK_FILE}

##
# Save the header
GEO_WPK_FILE_HEADER=${GEO_WPK_FILE}.tmp.hdr
grep "^pk\(.\+\)" ${GEO_WPK_FILE} > ${GEO_WPK_FILE_HEADER}

##
# Remove the header (first line)
GEO_WPK_FILE_TMP=${GEO_WPK_FILE}.tmp
sed -i -e "s/^pk\(.\+\)//g" ${GEO_WPK_FILE}
sed -i -e "/^$/d" ${GEO_WPK_FILE}

##
# Sort the file
sort -t'^' -k1,1 ${GEO_WPK_FILE} > ${SORTED_GEO_WPK_FILE}
\cp -f ${SORTED_GEO_WPK_FILE} ${GEO_WPK_FILE}

##
# Note: no longer needed, as the data files are now sorted thanks to the primary key.
#       To be removed once proved to be stable.
#
# Eliminate the city POR (points of reference) when those duplicate the
# IATA code of the corresponding airport (e.g., SFO, LAX). Note that some
# cities do not duplicate the IATA of their related airports (e.g., PAR, CHI,
# LON).
# a. Replace the 'NULL' fields by 'ZZZZ', so as to place them at the end
#sed -i -e "s/^\([A-Z0-9]\{3\}-[A-Z]\{1,3\}\)\^\([A-Z0-9]\{3\}\)\^ZZZZ\^\(.\+\)/\1\^\2\^NULL\^\3/g" ${GEO_WPK_FILE_TMP}
# b. Sort the file by the primary key
#sort -t'^' -k1,1 ${GEO_WPK_FILE_TMP} > ${SORTED_GEO_WPK_FILE}
#\rm -f ${GEO_WPK_FILE_TMP}
# c. Remove the rows duplicating the primary key
#uniq -w 3 ${SORTED_GEO_WPK_FILE} > ${GEO_WPK_FILE_TMP}
#\mv -f ${GEO_WPK_FILE_TMP} ${SORTED_GEO_WPK_FILE}
# d. Replace back the (remaining) 'ZZZZ' fields by 'NULL'
#sed -i -e "s/^\([A-Z0-9]\{3\}-[A-Z]\{1,3\}\)\^\([A-Z0-9]\{3\}\)\^NULL\^\(.\+\)/\1\^\2\^ZZZZ\^\3/g" ${SORTED_GEO_WPK_FILE}

##
# Only four columns/fields are kept in that version of the file:
#  * Primary key (IATA code - location type)
#  * Airport/city IATA code
#  * Geographical coordinates (latitude, longitude).
cut -d'^' -f 1,2,7,8 ${SORTED_GEO_WPK_FILE} > ${SORTED_CUT_GEO_WPK_FILE}

##
# Re-add the header
cat ${GEO_WPK_FILE_HEADER} ${GEO_WPK_FILE} > ${GEO_WPK_FILE_TMP}
sed -i -e "/^$/d" ${GEO_WPK_FILE_TMP}
\mv -f ${GEO_WPK_FILE_TMP} ${GEO_WPK_FILE}
\rm -f ${GEO_WPK_FILE_HEADER}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${GEO_WPK_FILE}', '${SORTED_GEO_WPK_FILE}' and '${SORTED_CUT_GEO_WPK_FILE}' files have been derived from '${GEO_RAW_FILE}'."
echo

