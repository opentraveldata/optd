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
	echo "\cp -f ../ORI/ori_por.csv ${TMP_DIR}ori_airports.csv"
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
GEO_NEW_BEST_KNOWN_FILE_FILENAME=best_new_coordinates_known_so_far.csv
# Geo data files
GEO_ORI_FILE=${TMP_DIR}${GEO_ORI_FILE_FILENAME}
GEO_BEST_KNOWN_FILE=${TMP_DIR}${GEO_BEST_KNOWN_FILE_FILENAME}
GEO_NEW_BEST_KNOWN_FILE=${TMP_DIR}${GEO_NEW_BEST_KNOWN_FILE_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<ORI-maintained file> [<File of best known coordinates>]]"
	echo "  - Default name for the ORI-maintained file: '${GEO_ORI_FILE}'"
	echo "  - Default name for the file of best known geographical coordinates: '${GEO_BEST_KNOWN_FILE}'"
	echo " The new candidate for the file of best known coordinates is: '${GEO_NEW_BEST_KNOWN_FILE}'"
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
GEO_ALL_BEST=${GEO_NEW_BEST_KNOWN_FILE}.tmp.all.best
GEO_ALL_ORI=${GEO_NEW_BEST_KNOWN_FILE}.tmp.all.ori
GEO_FULL_ORI=${GEO_NEW_BEST_KNOWN_FILE}.tmp.full
GEO_FULL_TMP=${GEO_NEW_BEST_KNOWN_FILE}.tmp
join -t'^' -a 1 ${GEO_BEST_KNOWN_FILE} ${GEO_ORI_FILE} > ${GEO_ALL_BEST}
join -t'^' -a 2 ${GEO_BEST_KNOWN_FILE} ${GEO_ORI_FILE} > ${GEO_ALL_ORI}
cat ${GEO_ALL_BEST} ${GEO_ALL_ORI} > ${GEO_FULL_ORI}
sed -i -e "/^$/d" ${GEO_FULL_ORI}
sort -t'^' -k1,1 ${GEO_FULL_ORI} | uniq -w 3 > ${GEO_FULL_TMP}
\mv -f ${GEO_FULL_TMP} ${GEO_FULL_ORI}

##
# Reduce entries (IATA codes) unknown by the file of best known coordinates, so
# that the CSV file can be properly parsed. For all the known entries (IATA
# codes), keep the entry of the file of best known coordinates.
AWK_REDUCER=${EXEC_PATH}reduce_best_known_coordinates_from_airports_csv.awk
awk -F'^' -v idx=1 -f ${AWK_REDUCER} ${GEO_FULL_ORI} > ${GEO_NEW_BEST_KNOWN_FILE}
\rm -f ${GEO_ALL_BEST} ${GEO_ALL_ORI} ${GEO_FULL_ORI}


##
# Reporting
GEO_BEST_DIFF_FILE=${TMP_DIR}best_diff.txt
comm -13 ${GEO_BEST_KNOWN_FILE} ${GEO_NEW_BEST_KNOWN_FILE} > ${GEO_BEST_DIFF_FILE}
DIFF_NB=`wc -l ${GEO_BEST_DIFF_FILE} | cut -d' ' -f1`
\rm -f ${GEO_BEST_DIFF_FILE}
DIFF_ALL_NB=`wc -l ${GEO_NEW_BEST_KNOWN_FILE} | cut -d' ' -f1`
echo
echo "There are ${DIFF_NB} differences between '${GEO_BEST_KNOWN_FILE}' and '${GEO_NEW_BEST_KNOWN_FILE}',"
echo "over ${DIFF_ALL_NB} lines in that latter data file. To see them:"
echo "diff -y -W 220 ${GEO_BEST_KNOWN_FILE} ${GEO_NEW_BEST_KNOWN_FILE} | less"
echo

##
# Cleaning
echo
echo "In order to clean the temporary files, simply do:"
echo "\rm -f ${GEO_ORI_FILE} ${GEO_BEST_KNOWN_FILE} ${GEO_NEW_BEST_KNOWN_FILE}"
echo

