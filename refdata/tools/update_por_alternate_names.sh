#!/bin/bash
#
# That script generates, from the ORI-maintained POR data file, the two data
# files suitable for OpenTrep, namely 'trep_place_details.csv' and
# 'trep_place_names.csv'. Those files are maintained in the /refdata/trep/admin
# sub-directory of the OpenTravelData project:
# http://github.com/opentraveldata/optd.
#
# One parameter is optional for this script:
# - the file-path of the ORI-maintained POR public data file.
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
# Input
ORI_POR_FILENAME=ori_por_public.csv
SORTED_ORI_POR=sorted_${ORI_POR_FILENAME}
SORTED_CUT_ORI_POR=cut_sorted_${ORI_POR_FILENAME}

##
# Targets
TREP_DETAILS_FILENAME=trep_place_details.csv
TREP_NAMES_FILENAME=trep_place_names.csv

##
#
ORI_POR=../ORI/${ORI_POR_FILENAME}
TREP_DETAILS_FILE=${TMP_DIR}${TREP_DETAILS_FILENAME}
TREP_NAMES_FILE=${TMP_DIR}${TREP_NAMES_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "From the ORI-maintained POR data file, that script generates (into the '${TMP_DIR}' directory) the two data files suitable for OpenTrep,"
	echo "namely '${TREP_DETAILS_FILE}' and '${TREP_NAMES_FILE}'."
	echo
	echo "Usage: $0 [<ORI-maintained POR public file>]"
	echo "  - Default name for the ORI-maintained POR public file: '${ORI_POR}'"
	echo
	exit -1
fi

##
# Data dump file with geographical coordinates
if [ "$1" != "" ];
then
	ORI_POR="$1"
	ORI_POR_FILENAME=`basename ${ORI_POR}`
	SORTED_ORI_POR=sorted_${ORI_POR_FILENAME}
	SORTED_CUT_ORI_POR=cut_sorted_${ORI_POR_FILENAME}
	if [ "${ORI_POR}" = "${ORI_POR_FILENAME}" ]
	then
		ORI_POR="${TMP_DIR}${ORI_POR}"
	fi
fi
SORTED_ORI_POR=${TMP_DIR}${SORTED_ORI_POR}
SORTED_CUT_ORI_POR=${TMP_DIR}${SORTED_CUT_ORI_POR}

if [ ! -f "${ORI_POR}" ]
then
	echo
	echo "The '${ORI_POR}' file does not exist."
	echo
	exit -1
fi

##
# First, remove the header (first line)
ORI_POR_TMP=${TMP_DIR}${ORI_POR_FILENAME}.tmp
sed -e "s/^iata_code\(.\+\)//g" ${ORI_POR} > ${ORI_POR_TMP}
sed -i -e "/^$/d" ${ORI_POR_TMP}


##
# The ORI-maintained POR file is sorted according to the IATA code (as is the
# RFD data dump), just to be sure.
sort -t'^' -k 1,1 ${ORI_POR_TMP} > ${SORTED_ORI_POR}
\rm -f ${ORI_POR_TMP}

##
# Preparation step
echo
echo "Preparation step"
echo "----------------"
echo "The '${SORTED_ORI_POR}' file has been derived from '${ORI_POR}'."
echo

##
# Generate the file with the names related to the ORI places (POR)
UPDATER_SCRIPT_DETAILS=${EXEC_PATH}update_por_details.awk
awk -F'^' -f ${UPDATER_SCRIPT_DETAILS} ${SORTED_ORI_POR} > ${TREP_DETAILS_FILE}

##
# Generate the file with the names related to the ORI places (POR)
UPDATER_SCRIPT_NAMES=${EXEC_PATH}update_por_alternate_names.awk
awk -F'^' -f ${UPDATER_SCRIPT_NAMES} ${SORTED_ORI_POR} > ${TREP_NAMES_FILE}

##
# Reporting
echo
echo "Reporting"
echo "---------"
echo "See the '${TREP_DETAILS_FILE}' and '${TREP_NAMES_FILE}' files:"
echo "less ${TREP_DETAILS_FILE} ${TREP_NAMES_FILE}"
echo

