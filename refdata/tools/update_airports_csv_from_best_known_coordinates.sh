#!/bin/bash
#
# Two parameters are optional for this script:
# - the ORI-maintained file (or a local copy of it)
# - the file of best known geographical coordinates
#

displayORIDetails() {
	echo
	echo "The ORI-maintained data files can be obtained from this project (OpenTravelData:"
	echo "http://github.com/opentraveldata/optd). For instance:"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/optd.git optdgit"
	echo "cd optdgit/refdata/tools"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "\cp -f ../ORI/ORI_Simple_Airports_Database_Table.csv ${TMP_DIR}ori_airports.csv"
	echo "\cp -f ../ORI/best_coordinates_known_so_far.csv ${TMP_DIR}"
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
# Geo data files
GEO_ORI_FILE_FILENAME=ori_airports.csv
GEO_BEST_KNOWN_FILE_FILENAME=best_coordinates_known_so_far.csv
GEO_ORI_NEW_FILE_FILENAME=ori_new_airports.csv
# Geo data files
GEO_ORI_FILE=${TMP_DIR}${GEO_ORI_FILE_FILENAME}
GEO_BEST_KNOWN_FILE=${TMP_DIR}${GEO_BEST_KNOWN_FILE_FILENAME}
GEO_ORI_NEW_FILE=${TMP_DIR}${GEO_ORI_NEW_FILE_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<ORI-maintained file> [<File of best known coordinates>]]"
	echo "  - Default name for the ORI-maintained file: '${GEO_ORI_FILE}'"
	echo "  - Default name for the file of best known geographical coordinates: '${GEO_BEST_KNOWN_FILE}'"
	echo " The new candidate for the ORI-maintained file is: '${GEO_ORI_NEW_FILE}'"
	echo
	exit -1
fi

##
# ORI-maintained file
if [ "$1" != "" ];
then
	GEO_ORI_FILE=$1
fi

if [ ! -f "${GEO_ORI_FILE}" ]
then
	echo
	echo "The '${GEO_ORI_FILE}' file does not exist."
	if [ "$1" = "" ];
	then
		displayORIDetails
		echo "The default name of the ORI-maintained file is '${GEO_ORI_FILE}'."
		echo
	fi
	exit -1
fi

##
# File of best known coordinates
if [ "$2" != "" ];
then
	GEO_BEST_KNOWN_FILE="$2"
fi

if [ ! -f "${GEO_BEST_KNOWN_FILE}" ]
then
	echo
	echo "The '${GEO_BEST_KNOWN_FILE}' file does not exist."
	if [ "$2" = "" ];
	then
		displayORIDetails
		echo "The default name of the file of best known coordinates is '${GEO_BEST_KNOWN_FILE}'."
		echo
	fi
	exit -1
fi

##
# Aggregate both the file of best known coordinates together with the
# ORI-maintained file.
join -t'^' -a 1 -e NULL ${GEO_BEST_KNOWN_FILE} ${GEO_ORI_FILE} > ${GEO_ORI_NEW_FILE}.tmp

##
# Expand unknown entries (IATA codes), so that the CSV file can be properly
# parsed. For all the known entries (IATA codes), replace the old ORI
# coordinates by the best known ones.
awk -F'^' '{printf ($1); if (NF == 3) {printf ("^UNKNOWN^UNKNOWN^UNKNOWN/ZZ^ZZZ^Y^NULL^ZZ^ZZZZZ^ITZ1^ZZ^" $2 "^" $3)} else {for (i=4; i<=18; i=i+1) {printf ("^" $i)}} printf ("\n")}' ${GEO_ORI_NEW_FILE}.tmp > ${GEO_ORI_NEW_FILE}
\rm -f ${GEO_ORI_NEW_FILE}.tmp
