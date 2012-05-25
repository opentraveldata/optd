#!/bin/bash

##
#
TMP_DIR=./

##
# Input data file
GEO_FILENAME=innovata_stations.csv
GEO_FILE=../Innovata/${GEO_FILENAME}

##
# Output data file
GEO_NEW_FILENAME=new_${GEO_FILENAME}
GEO_NEW_FILE=${TMP_DIR}${GEO_NEW_FILENAME}
GEO_NEW_FILE_TMP=${GEO_NEW_FILE}.tmp

##
#
\cp -f ${GEO_FILE} ${GEO_NEW_FILE}
sed -i -e "s/\t/\^/g" ${GEO_NEW_FILE}
sed -i -e "s/\([0-9][0-9][0-9][0-9][0-9][0-9]\)S/-\1/g" ${GEO_NEW_FILE}
sed -i -e "s/\([0-9][0-9][0-9][0-9][0-9][0-9]\)N/\1/g" ${GEO_NEW_FILE}
sed -i -e "s/\([0-9][0-9][0-9][0-9][0-9][0-9][0-9]\)W/-\1/g" ${GEO_NEW_FILE}
sed -i -e "s/\([0-9][0-9][0-9][0-9][0-9][0-9][0-9]\)E/\1/g" ${GEO_NEW_FILE}
awk -F'^' '{printf ($1 "^" $2 "^" $3 "^" $4 "^" $5 "^" $6 "^" $9 "^" $10 "^"); printf ("%6.4f", $7 / 10000.0); printf ("^%7.4f\n", $8 / 10000.0)}' ${GEO_NEW_FILE} > ${GEO_NEW_FILE_TMP}
\mv -f ${GEO_NEW_FILE_TMP} ${GEO_NEW_FILE}

echo "New file: less ${GEO_NEW_FILE}"

