#!/bin/bash
#
# Two parameters are optional for this script:
# - the first file of geographical coordinates
# - the second file of geographical coordinates
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
# Geo data files
GEO_FILE_1_FILENAME=cut_sorted_dump_from_geonames.csv
GEO_FILE_2_FILENAME=best_coordinates_known_so_far.csv
AIRPORT_POP_FILENAME=cut_sorted_ref_airport_popularity.csv
# Comparison files
COMP_FILE_COORD_FILENAME=por_comparison_coord.csv
COMP_FILE_DIST_FILENAME=por_comparison_dist.csv
POR_MAIN_DIFF_FILENAME=por_main_diff.csv
# Minimal distance triggering a difference (in km)
COMP_MIN_DIST=10

##
# Geo data files
GEO_FILE_1=${TMP_DIR}${GEO_FILE_1_FILENAME}
GEO_FILE_2=${TMP_DIR}${GEO_FILE_2_FILENAME}
AIRPORT_POP=${TMP_DIR}${AIRPORT_POP_FILENAME}
# Comparison files
COMP_FILE_COORD=${TMP_DIR}${COMP_FILE_COORD_FILENAME}
COMP_FILE_DIST=${TMP_DIR}${COMP_FILE_DIST_FILENAME}
POR_MAIN_DIFF=${TMP_DIR}${POR_MAIN_DIFF_FILENAME}


if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Geo data file 1> [<Geo data file 2>]]"
	echo "  - Default name for the geo data file #1: '${GEO_FILE_1}'"
	echo "  - Default name for the geo data file #2: '${GEO_FILE_2}'"
	echo "  - Default name for the airport popularity: '${AIRPORT_POP}'"
	echo "  - Default distance (in km) triggering a difference: '${COMP_MIN_DIST}'"
	echo
	exit -1
fi

##
# Local helper scripts
PREPARE_EXEC="bash ${EXEC_PATH}prepare_geonames_dump_file.sh"
PREPARE_POP_EXEC="bash ${EXEC_PATH}prepare_popularity.sh"

##
# First data file with geographical coordinates
if [ "$1" != "" ];
then
	GEO_FILE_1=$1
	GEO_FILE_1_FILENAME=`basename ${GEO_FILE_1}`
	if [ "${GEO_FILE_1}" = "${GEO_FILE_1_FILENAME}" ]
	then
		GEO_FILE_1="${TMP_DIR}${GEO_FILE_1_FILENAME}"
	fi
fi

if [ ! -f "${GEO_FILE_1}" ]
then
	echo "The '${GEO_FILE_1}' file does not exist."
	if [ "$1" = "" ];
	then
		${PREPARE_EXEC} --geonames
		echo "The default name of the Geonames data dump copy is '${GEO_FILE_1}'."
		echo
	fi
	exit -1
fi


##
# Second data file with geographical coordinates
if [ "$2" != "" ];
then
	GEO_FILE_2=$2
	GEO_FILE_2_FILENAME=`basename ${GEO_FILE_2}`
	if [ "${GEO_FILE_2}" = "${GEO_FILE_2_FILENAME}" ]
	then
		GEO_FILE_2="${TMP_DIR}${GEO_FILE_2_FILENAME}"
	fi
fi


##
# Data file with airport popularity
if [ "$3" != "" ];
then
	AIRPORT_POP=$3
	AIRPORT_POP_FILENAME=`basename ${AIRPORT_POP}`
	if [ "${AIRPORT_POP}" = "${AIRPORT_POP_FILENAME}" ]
	then
		AIRPORT_POP="${TMP_DIR}${AIRPORT_POP_FILENAME}"
	fi
fi

if [ ! -f "${AIRPORT_POP}" ]
then
	echo
	echo "The '${AIRPORT_POP}' file does not exist."
	if [ "$3" = "" ];
	then
		${PREPARE_POP_EXEC} --popularity
		echo "The default name of the airport popularity copy is '${AIRPORT_POP}'."
		echo
	fi
	exit -1
fi


##
# Minimal distance (in km) triggering a difference
if [ "$4" != "" ]
then
	DIFF_EXPR=`echo "$4 / 1" | bc 2> /dev/null`
	if [ "${DIFF_EXPR}" = "" ]
	then
		echo
		echo "The minimal distance (in km) must be a number greater than zero, and less than 65000. It is currently $4."
		echo
		exit -1
	fi
	if [ ${DIFF_EXPR} -lt 0 -o ${DIFF_EXPR} -gt 65000 ]
	then
		echo
		echo "The minimal distance (in km) must be greater than (or equal to) zero, and less than 65000. It is currently $4."
		echo
		exit -1
	fi
	COMP_MIN_DIST=$4
fi


##
# For each airport/city code, join the two geographical coordinate sets.
COMP_FILE_COORD_TMP=${COMP_FILE_COORD}.tmp2
join -t'^' -a 1 -e NULL ${GEO_FILE_1} ${GEO_FILE_2} > ${COMP_FILE_COORD_TMP}

##
# For each airport/city code, join the airport popularity.
join -t'^' -a 1 -e 0 ${COMP_FILE_COORD_TMP} ${AIRPORT_POP} > ${COMP_FILE_COORD}
\rm -f ${COMP_FILE_COORD_TMP}

##
# Suppress empty coordinate fields, from the geonames dump file:
#sed -i -e 's/\^NULL/\^/g' ${COMP_FILE_COORD}

##
# For each airport/city code, calculate the distance between the two
# geographical coordinate sets.
AWK_DIST=${EXEC_PATH}distance.awk
awk -F '^' -f ${AWK_DIST} ${COMP_FILE_COORD} > ${COMP_FILE_DIST}

##
# Count the differences
POR_ALL_DIFF_NB=`wc -l ${COMP_FILE_DIST} | cut -d' ' -f1`

##
# Filter the difference data file for all the distances greater than
# ${COMP_MIN_DIST} (in km; by default 1km).
POR_MAIN_DIFF_TMP=${POR_MAIN_DIFF}.tmp
awk -F'^' -v comp_min_dist=${COMP_MIN_DIST} '{if ($2 >= comp_min_dist) {printf($1 "^" $2 "^" $3 "^" $4 "\n")}}' ${COMP_FILE_DIST} > ${POR_MAIN_DIFF_TMP}

##
# Sort the differences, weighted by the popularity of the airport (equal to 1
# when not specified), from the greatest to the least.
sort -t'^' -k4nr -k2nr -k1 ${POR_MAIN_DIFF_TMP} > ${POR_MAIN_DIFF}
echo "dep_city^distance^nb_of_pax^dist_weighted_by_pop" | cat - ${POR_MAIN_DIFF} > ${POR_MAIN_DIFF_TMP}
\mv -f ${POR_MAIN_DIFF_TMP} ${POR_MAIN_DIFF}

##
# Count the differences
POR_MAIN_DIFF_NB=`wc -l ${POR_MAIN_DIFF} | cut -d' ' -f1`

##
# Clean
\rm -f ${COMP_FILE_COORD} ${COMP_FILE_DIST}

##
# Reporting
if [ ${POR_MAIN_DIFF_NB} -gt 0 ]
then
	echo
	echo "Comparison step"
	echo "---------------"
	echo "To see the ${POR_MAIN_DIFF_NB} main differences (greater than ${COMP_MIN_DIST} kms), over ${POR_ALL_DIFF_NB} differences in all,"
	echo "between the Geonames coordinates ('${GEO_FILE_1}') and the best known ones ('${GEO_FILE_2}'),"
	echo "sorted by distance (in km), just do: less ${POR_MAIN_DIFF}"
	echo
else
	echo
	echo "Comparison step"
	echo "---------------"
	echo "There are no difference (greater than ${COMP_MIN_DIST} kms) between the"
	echo "Geonames coordinates and the best known ones."
	echo
	\rm -f ${POR_MAIN_DIFF}
fi
