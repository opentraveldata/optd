#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from RFD.
#

displayRFDDetails() {
	if [ -z "${DARFD}" ]
	then
		export DARFD=~/dev/dataanalysis/dataanalysisgit/data_generation
	fi
	if [ -z "${MYCURDIR}" ]
	then
		export MYCURDIR=`pwd`
	fi
	echo
	echo "# The data dump from Amadeus RFD can be obtained from this project"
	echo "# (http://gitorious.orinet.nce.amadeus.net/dataanalysis/dataanalysis.git). For instance:"
	echo "MYCURDIR=${MYCURDIR}"
	echo "DARFD=${DARFD}"
	echo "mkdir -p ~/dev/dataanalysis"
	echo "cd ~/dev/dataanalysis"
	echo "git clone git://gitorious.orinet.nce.amadeus.net/dataanalysis/dataanalysis.git dataanalysisgit"
	echo "cd ${DARFD}/RFD"
	echo "# The following script fetches a SQLite file, holding Amadeus RFD data,"
	echo "# and translates it into three MySQL-compatible SQL files:"
	echo "./fetch_sqlite_rfd.sh # it may take several minutes"
	echo "# It produces three create_*_rfd_*YYYYMMDD.sql files, which are then"
	echo "# used by the following script, in order to load the RFD data into MySQL:"
	echo "./create_rfd_user.sh"
	echo "./create_rfd_db.sh"
	echo "./create_all_tables.sh geo rfd_rfd YYYYMMDD"
	echo "./fetch_sqlite_rfd.sh # it may take several minutes"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "# The MySQL CRB_CITY table has then to be exported into a CSV file."
	echo "${DARFD}/por/extract_por_rfd_crb_city.sh geo rfd_rfd"
	echo "\cp -f ${TMP_DIR}/por_all_rfd_20120310.csv ${TMP_DIR}/dump_from_crb_city.csv"
	echo "\cp -f ${OPTDDIR}/ORI/best_coordinates_known_so_far.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/ORI/ref_airport_popularity.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/ORI/ori_por.csv ${TMP_DIR}ori_airports.csv"
	echo "${DARFD}/update_airports_csv_after_getting_crb_city_dump.sh"
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
# Tools path
TOOLS_DIR=${EXEC_PATH}../tools/

##
#
DUMP_FROM_RFD_FILENAME=dump_from_crb_city.csv
SORTED_DUMP_FROM_RFD=sorted_${DUMP_FROM_RFD_FILENAME}
SORTED_CUT_DUMP_FROM_RFD=cut_sorted_${DUMP_FROM_RFD_FILENAME}
#
DUMP_FROM_RFD=${TOOLS_DIR}${DUMP_FROM_RFD_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Amadeus RFD CRB_CITY data dump file>]"
	echo "  - Default name for the RFD CRB_CITY data dump file: '${DUMP_FROM_RFD}'"
	echo
	exit -1
fi
#
if [ "$1" = "-r" -o "$1" = "--rfd" ];
then
	displayRFDDetails
	exit -1
fi

##
# Data dump file with geographical coordinates
if [ "$1" != "" ];
then
	DUMP_FROM_RFD="$1"
	DUMP_FROM_RFD_FILENAME=`basename ${DUMP_FROM_RFD}`
	SORTED_DUMP_FROM_RFD=sorted_${DUMP_FROM_RFD_FILENAME}
	SORTED_CUT_DUMP_FROM_RFD=cut_sorted_${DUMP_FROM_RFD_FILENAME}
	if [ "${DUMP_FROM_RFD}" = "${TOOLS_DIR}${DUMP_FROM_RFD_FILENAME}" ]
	then
		DUMP_FROM_RFD="${TOOLS_DIR}${DUMP_FROM_RFD}"
	fi
fi
SORTED_DUMP_FROM_RFD=${TMP_DIR}${SORTED_DUMP_FROM_RFD}
SORTED_CUT_DUMP_FROM_RFD=${TMP_DIR}${SORTED_CUT_DUMP_FROM_RFD}

if [ ! -f "${DUMP_FROM_RFD}" ]
then
	echo "The '${DUMP_FROM_RFD}' file does not exist."
	if [ "$1" = "" ];
	then
		displayRFDDetails
	fi
	exit -1
fi


##
# First, remove the header (first line)
DUMP_FROM_RFD_TMP=${DUMP_FROM_RFD}.tmp
sed -e "s/^code\(.\+\)//g" ${DUMP_FROM_RFD} > ${DUMP_FROM_RFD_TMP}
sed -i -e "/^$/d" ${DUMP_FROM_RFD_TMP}


##
# The RFD dump file is sorted according to the IATA code (as is the file of
# best coordinates), just to be sure.
sort -t'^' -k 1,1 ${DUMP_FROM_RFD_TMP} > ${SORTED_DUMP_FROM_RFD}
\rm -f ${DUMP_FROM_RFD_TMP}

##
# Only three columns/fields are kept in that version of the file:
# the airport/city IATA code and the geographical coordinates (latitude,
# longitude).
cut -d'^' -f 1,14,15 ${SORTED_DUMP_FROM_RFD} > ${SORTED_CUT_DUMP_FROM_RFD}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${SORTED_DUMP_FROM_RFD}' and '${SORTED_CUT_DUMP_FROM_RFD}' files have been derived from '${DUMP_FROM_RFD}'."
echo

