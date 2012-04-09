#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file for PageRanked airports.
#

displayPopularityDetails() {
	if [ -z "${OPTDDIR}" ]
	then
		export OPTDDIR=~/dev/geo/optdgit/refdata
	fi
	if [ -z "${MYCURDIR}" ]
	then
		export MYCURDIR=`pwd`
	fi
	echo
	echo "The data dump for PageRanked airports can be obtained from this project (OpenTravelData:"
	echo "http://github.com/opentraveldata/optd). For instance:"
	echo "MYCURDIR=`pwd`"
	echo "OPTDDIR=${OPTDDIR}"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/optd.git optdgit"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "\cp -f ${OPTDDIR}/ORI/ref_airport_pageranked.csv ${TMP_DIR}"
	echo "${OPTDDIR}/tools/update_airports_csv_after_getting_geonames_iata_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo
}

##
#
AIRPORT_PG_FILENAME=ref_airport_pageranked.csv

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
# If the PageRanked airport file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${AIRPORT_PG_FILENAME} ]
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
AIRPORT_PG_SORTED=sorted_${AIRPORT_PG_FILENAME}
AIRPORT_PG_SORTED_CUT=cut_sorted_${AIRPORT_PG_FILENAME}
#
AIRPORT_PG=${TMP_DIR}${AIRPORT_PG_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<PageRanked airport data file>]"
	echo "  - Default name for the PageRanked airport data file: '${AIRPORT_PG}'"
	echo
	exit -1
fi
#
if [ "$1" = "-g" -o "$1" = "--popularity" ];
then
	displayPopularityDetails
	exit -1
fi

##
# Data file
if [ "$1" != "" ];
then
	AIRPORT_PG="$1"
	AIRPORT_PG_FILENAME=`basename ${AIRPORT_PG}`
	AIRPORT_PG_SORTED=sorted_${AIRPORT_PG_FILENAME}
	AIRPORT_PG_SORTED_CUT=cut_sorted_${AIRPORT_PG_FILENAME}
	if [ "${AIRPORT_PG}" = "${AIRPORT_PG_FILENAME}" ]
	then
		AIRPORT_PG="${TMP_DIR}${AIRPORT_PG}"
	fi
fi
AIRPORT_PG_SORTED=${TMP_DIR}${AIRPORT_PG_SORTED}
AIRPORT_PG_SORTED_CUT=${TMP_DIR}${AIRPORT_PG_SORTED_CUT}

if [ ! -f "${AIRPORT_PG}" ]
then
	echo "The '${AIRPORT_PG}' file does not exist."
	if [ "$1" = "" ];
	then
		displayPopularityDetails
	fi
	exit -1
fi

##
# First, remove the header (first line).
AIRPORT_PG_TMP=${AIRPORT_PG}.tmp
# As of now (April 2012), there is no header.
\cp -f ${AIRPORT_PG} ${AIRPORT_PG_TMP}
#sed -e "s/^region_code\(.\+\)//g" ${AIRPORT_PG} > ${AIRPORT_PG_TMP}
#sed -i -e "/^$/d" ${AIRPORT_PG_TMP}


##
# The PageRanked airport file should be sorted according to the code (as are
# the Geonames data dump and the file of best coordinates).
sort -t'^' -k 1,1 ${AIRPORT_PG_TMP} > ${AIRPORT_PG_SORTED}
\rm -f ${AIRPORT_PG_TMP}

##
# Only two columns/fields are kept in that version of the file:
# the airport/city IATA code and the PageRank.
# Note: as of now (April 2012), the file has got no other field. So, that step
# is useless.
cut -d'^' -f 1,2 ${AIRPORT_PG_SORTED} > ${AIRPORT_PG_SORTED_CUT}

##
# Convert the IATA codes from lower to upper letters
cat ${AIRPORT_PG_SORTED_CUT} | tr [:lower:] [:upper:] > ${AIRPORT_PG_TMP}
\mv -f ${AIRPORT_PG_TMP} ${AIRPORT_PG_SORTED_CUT}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${AIRPORT_PG_SORTED}' and '${AIRPORT_PG_SORTED_CUT}' files have been derived from '${AIRPORT_PG}'."
echo

