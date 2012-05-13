#!/bin/sh

##
# Input files
BST_FILENAME=best_coordinates_known_so_far.csv
GEO_FILE=dump_from_geonames.csv
BST_FILE=../ORI/${BST_FILENAME}

##
# Output files
BST_NEW_FILE=new_${BST_FILENAME}

##
#
if [ ! -f ${GEO_FILE} ]
then
	echo
	echo "The ${GEO_FILE} file is missing."
	echo "Hint: launch the ./preprepare_geonames_dump_file.sh script."
	echo
	exit -1
fi
#
if [ ! -f ${BST_FILE} ]
then
	echo
	echo "The ${BST_FILE} file is missing."
	echo "Hint: you probably launch the current script ($0) from another directory than <opentraveldata>/refdata/tools."
	echo
	exit -1
fi

##
# Extract the header into a temporary file
GEO_FILE_HEADER=${GEO_FILE}.tmp.hdr
grep "^iata\(.\+\)" ${GEO_FILE} > ${GEO_FILE_HEADER}

# Remove the header
sed -i -e "s/^iata\(.\+\)//g" ${GEO_FILE}
sed -i -e "/^$/d" ${GEO_FILE}

##
# Extract the POR having (0, 0) as coordinates
awk -F'^' '{if ($2 == 0 && $3 ==0) {printf ($1 "\n")}}' ${BST_FILE} > ${BST_NEW_FILE}
NB_ZERO_ROWS=`wc -l ${BST_NEW_FILE} | cut -d' ' -f1`

##
# Sort the list of POR
BST_FILE_TMP=${BST_NEW_FILE}.tmp
sort -t'^' -k1,1 ${BST_NEW_FILE} > ${BST_FILE_TMP}
\mv -f ${BST_FILE_TMP} ${BST_NEW_FILE}

##
# Join the coordinates of Geonames, next to the POR IATA codes
join -t'^' -a 1 ${BST_NEW_FILE} ${GEO_FILE} > ${BST_FILE_TMP}

# Reduce the lines
FIX_BST_REDUCER=fix_best_known_coordinates.awk
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_FILE_TMP} > ${BST_NEW_FILE}
NB_FIXED_ROWS=`wc -l ${BST_NEW_FILE} | cut -d' ' -f1`

##
# Join the coordinates of the pristine ORI file with the one of fixed
# coordinates.
join -t'^' -a 2 ${BST_NEW_FILE} ${BST_FILE} > ${BST_FILE_TMP}

# Replace the coordinates, when those latter have been fixed by Geonames.
# The trick is that the same AWK reducer is used. Indeed, the number of
# fields is different now, when compared to the former use case.
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_FILE_TMP} > ${BST_NEW_FILE}

##
# Re-add the header to the Geonames dump file
GEO_FILE_TMP=${GEO_FILE}.tmp
cat ${GEO_FILE_HEADER} ${GEO_FILE} > ${GEO_FILE_TMP}
\mv -f ${GEO_FILE_TMP} ${GEO_FILE}
\rm -f ${GEO_FILE_HEADER}

##
# Reporting
echo
echo "Reporting"
echo "---------"
echo "The ${BST_FILE} contains ${NB_ZERO_ROWS} POR with wrong coordinates."
echo "Among those, ${NB_FIXED_ROWS} have been fixed, thanks to Geonames."
echo "The ${BST_NEW_FILE} file intends to replace ${BST_FILE}:"
echo "wc -l ${BST_NEW_FILE} ${BST_FILE}"
echo "diff -c ${BST_NEW_FILE} ${BST_FILE} | less"
echo

