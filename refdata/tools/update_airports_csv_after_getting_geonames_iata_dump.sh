#!/bin/bash
#
# Three parameters are optional for this script:
# - the first file of geographical coordinates
# - the second file of geographical coordinates
# - the minimal distance (in km) triggering a difference
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
GEO_FILE_1_FILENAME=dump_from_geonames.csv
GEO_FILE_1_SORTED=sorted_${GEO_FILE_1_FILENAME}
GEO_FILE_1_SORTED_CUT=cut_${GEO_FILE_1_SORTED}
GEO_FILE_2_FILENAME=best_coordinates_known_so_far.csv
# Comparison files
POR_MAIN_DIFF_FILENAME=por_main_diff.csv
# Combined data files of both the other sources
GEO_COMBINED_FILE_FILENAME=new_airports.csv
# Minimal distance triggering a difference (in km)
COMP_MIN_DIST=10

##
# Geo data files
GEO_FILE_1=${TMP_DIR}${GEO_FILE_1_FILENAME}
GEO_FILE_2=${TMP_DIR}${GEO_FILE_2_FILENAME}
# Comparison files
POR_MAIN_DIFF=${TMP_DIR}${POR_MAIN_DIFF_FILENAME}
# Combined data files of both the other sources
GEO_COMBINED_FILE=${TMP_DIR}${GEO_COMBINED_FILE_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Geo data file #1> [<Geo data file #2>]]"
	echo "  - Default name for the geo data file #1: '${GEO_FILE_1}'"
	echo "  - Default name for the geo data file #2: '${GEO_FILE_2}'"
	echo "  - Default distance (in km) triggering a difference: '${COMP_MIN_DIST}'"
	echo
	exit -1
fi

##
# Local helper scripts
PREPARE_EXEC="bash ${EXEC_PATH}prepare_geonames_dump_file.sh"
COMPARE_EXEC="bash ${EXEC_PATH}compare_geo_files.sh"

##
# First data file with geographical coordinates
if [ "$1" != "" ];
then
	GEO_FILE_1=$1
	GEO_FILE_1_FILENAME=`basename ${GEO_FILE_1}`
	GEO_FILE_1_SORTED=sorted_${GEO_FILE_1_FILENAME}
	GEO_FILE_1_SORTED_CUT=cut_${GEO_FILE_1_SORTED}
	if [ "${GEO_FILE_1}" = "${GEO_FILE_1_FILENAME}" ]
	then
		GEO_FILE_1="${TMP_DIR}${GEO_FILE_1_FILENAME}"
	fi
fi
GEO_FILE_1_SORTED=${TMP_DIR}${GEO_FILE_1_SORTED}
GEO_FILE_1_SORTED_CUT=${TMP_DIR}${GEO_FILE_1_SORTED_CUT}

if [ ! -f "${GEO_FILE_1}" ]
then
	echo
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
# Prepare the Geonames dump file, exported from Geonames.
# Basically, the coordinates are extracted, in order to keep a data file with
# only three fields/columns: the airport/city code and the coordinates.
${PREPARE_EXEC} ${GEO_FILE_1}

# Second data file with geographical coordinates
if [ "$2" != "" ];
then
	GEO_FILE_2="$2"
fi

if [ ! -f "${GEO_FILE_2}" ]
then
	echo
	echo "The '${GEO_FILE_2}' file does not exist."
	if [ "$2" = "" ];
	then
		echo
		echo "Hint:"
		echo "\cp -f ${EXEC_PATH}../ORI/${GEO_FILE_2_FILENAME} ${TMP_DIR}"
		echo
	fi
	exit -1
fi

##
# Minimal distance (in km) triggering a difference
if [ "$3" != "" ]
then
	DIFF_EXPR=`echo "$3" | bc 2> /dev/null`
	if [ "${DIFF_EXPR}" = "" ]
	then
		echo
		echo "The minimal distance (in km) must be a number greater than zero, and less than 65000. It is currently $3."
		echo
		exit -1
	fi
	if [ ${DIFF_EXPR} -lt 1 -o ${DIFF_EXPR} -gt 65000 ]
	then
		echo
		echo "The minimal distance (in km) must be greater than zero, and less than 65000. It is currently $3."
		echo
		exit -1
	fi
	COMP_MIN_DIST=$3
fi

##
# The two files contain only three fields (the code and both coordinates).
# Note that the ${PREPARE_EXEC} (e.g., prepare_geonames_dump_file.sh) scrit
# prepares such a file for Geonames (named ${GEO_FILE_1_SORTED_CUT}, e.g.,
# cut_sorted_dump_from_geonames.csv) from the data dump (named ${GEO_FILE_1},
# e.g., dump_from_geonames.csv).
# The 'join' command aggregates:
#  * The three fields of the geonames dump file. That is the file #1 (standard
#    input here) for the join command.
#  * The two coordinates of the file of best coordinates (the code being
#    stripped by the join command). That is the file #2 for the join command.
# The 'join' command takes all the rows from the file #1 (geonames dump file):
# when there is no corresponding entry in the file of best coordinates, only
# the three (extracted) fields of the geonames dump file are kept.
# Hence, some lines have five fields (the code and both coordinates of the
# geonames dump file followed by the best coordinates), whereas a few others
# have only three fields (the code and both coordinates of the geonames dump
# file).
JOINED_COORD_1=${GEO_COMBINED_FILE}.tmp.1
join -t'^' -a 1 -e NULL ${GEO_FILE_1_SORTED_CUT} ${GEO_FILE_2} > ${JOINED_COORD_1}


# Sanity check
MIN_FIELD_NB=$(awk -F'^' 'BEGIN{n=10};{if (NF<n) {n=NF}}END{print n}' ${JOINED_COORD_1} | uniq | sort | uniq)

if [ "${MIN_FIELD_NB}" != "5" ];
then
	echo
	echo "Update step"
	echo "-----------"
	echo "Minimum number of fields in the new coordinate file should be 5. It is ${MIN_FIELD_NB}"
	echo "Problem!"
	echo "Check file ${JOINED_COORD}, which is a join of the coordinates from ${GEO_FILE_1_SORTED_CUT} and ${GEO_FILE_2}"
	echo
  exit
fi

##
# Operate the same way as above, except that, this time, the points of reference
# with the best known coordinates have the precedence over those of Geonames.
# Note that, however, when they exist, the Geonames coordinates themselves
# (not the point of reference) have the precedence over the "best known" ones.
JOINED_COORD_2=${GEO_COMBINED_FILE}.tmp.2
join -t'^' -a 2 -e NULL ${GEO_FILE_1_SORTED_CUT} ${GEO_FILE_2} > ${JOINED_COORD_2}

##
# Keep only the first three fields:
#  * The code and both the coordinates of the geonames dump file when they
#    exist.
#  * The code and the best coordinates when no entry exists in the geonames
#    dump file.
cut -d'^' -f 1-3 ${JOINED_COORD_1} > ${JOINED_COORD_1}.dup
\mv -f ${JOINED_COORD_1}.dup ${JOINED_COORD_1}
cut -d'^' -f 1-3 ${JOINED_COORD_2} > ${JOINED_COORD_2}.dup
\mv -f ${JOINED_COORD_2}.dup ${JOINED_COORD_2}

##
# Suppress empty coordinate fields, from the geonames dump file:
#sed -i -e 's/\^NULL/\^/g' ${JOINED_COORD}

##
# Re-aggregate all the fields, so that the format of the generated file be
# the same as the Geonames dump file.
JOINED_COORD_FULL=${JOINED_COORD_1}.tmp.full
paste -d'^' ${JOINED_COORD_1} ${GEO_FILE_1_SORTED} > ${JOINED_COORD_FULL}

##
# Filter and re-order a few fields, so that the format of the generated file be
# the same as the geonames dump file.
# The awk in the following line is likely to be affected by a change
# in the fields of the geonames dump file.
awk -F'^' '{printf($1); for (i=5;i<=7;i=i+1) {printf("^" $i)}; print "^" $2 "^" $3 "^" $10 "^" $11 "^" $12 "^" $13 "^" $14}' ${JOINED_COORD_FULL} > ${GEO_COMBINED_FILE}

##
# Do some reporting
POR_NB_COMMON=`comm -12 ${JOINED_COORD_1} ${JOINED_COORD_2} | wc -l`
POR_NB_FILE1=`comm -23 ${JOINED_COORD_1} ${JOINED_COORD_2} | wc -l`
POR_NB_FILE2=`comm -13 ${JOINED_COORD_1} ${JOINED_COORD_2} | wc -l`
echo
echo "Reporting step"
echo "--------------"
echo "'${GEO_FILE_1}' and '${GEO_FILE_2}' have got ${POR_NB_COMMON} common lines."
echo "'${GEO_FILE_1}' has got ${POR_NB_FILE1} POR, missing from '${GEO_FILE_2}'"
echo "'${GEO_FILE_2}' has got ${POR_NB_FILE2} POR, missing from '${GEO_FILE_1}'"
echo

GEO_FILE_1_MISSING=""
if [ ${POR_NB_FILE2} -gt 0 ]
then
	GEO_FILE_1_MISSING=${GEO_FILE_1}.missing
	comm -13 ${JOINED_COORD_1} ${JOINED_COORD_2} > ${GEO_FILE_1_MISSING}
	POR_MISSING_GEONAMES_NB=`wc -l ${GEO_FILE_1_MISSING} | cut -d' ' -f1`
	echo
	echo "Suggestion step"
	echo "---------------"
	echo "${POR_MISSING_GEONAMES_NB} points of reference (POR) are missing from Geonames ('${GEO_FILE_1}')."
	echo "They can be displayed with: less ${GEO_FILE_1_MISSING}"
	echo
fi

GEO_FILE_2_MISSING=""
if [ ${POR_NB_FILE1} -gt 0 ]
then
	GEO_FILE_2_MISSING=${GEO_FILE_2}.missing
	comm -23 ${JOINED_COORD_1} ${JOINED_COORD_2} > ${GEO_FILE_2_MISSING}
	echo
	echo "Suggestion step"
	echo "---------------"
	echo "To incorporate the missing POR into '${GEO_FILE_2}', just do:"
	echo "cat ${GEO_FILE_2} ${GEO_FILE_2_MISSING} | sort -t'^' -k1,1 > ${GEO_FILE_2}.tmp && \mv -f ${GEO_FILE_2}.tmp ${GEO_FILE_2} && \rm -f ${GEO_FILE_2_MISSING}"
	echo
fi

##
# Compare the Geonames coordinates to the best known ones (unil now).
# It generates a data file (${POR_MAIN_DIFF}, e.g., por_main_diff.csv)
# containing the greatest distances (in km), for each airport/city, between
# both sets of coordinates (Geonames and best known ones).
${COMPARE_EXEC} ${GEO_FILE_1_SORTED_CUT} ${GEO_FILE_2} ${COMP_MIN_DIST}

##
# Clean
if [ "${TMP_DIR}" != "/tmp/por/" ]
then
	\rm -f ${JOINED_COORD} ${JOINED_COORD_FULL} ${JOINED_COORD_1} ${JOINED_COORD_2}
	\rm -f ${GEO_FILE_1_SORTED} ${GEO_FILE_1_SORTED_CUT}
fi


##
# Reporting
echo
echo "Update step"
echo "-----------"
echo "The new airports.csv data file is ${GEO_COMBINED_FILE}"
echo "Check that the format of the new file is the same as the old file before replacing!"
echo

echo
echo "If you want to do some cleaning everything:"
if [ "${TMP_DIR}" = "/tmp/por/" ]
then
	echo "\rm -rf ${TMP_DIR}"
else
	echo "\rm -f ${GEO_FILE_2} ${GEO_FILE_1_MISSING} ${GEO_COMBINED_FILE} ${POR_MAIN_DIFF}"
fi
echo
