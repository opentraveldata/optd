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
# AWK script
INN_PREP_SCRIPT=prepare_innovata.awk
awk -F'\t' -f ${INN_PREP_SCRIPT} ${GEO_FILE} > ${GEO_NEW_FILE}

##
# Reporting
echo "New file: less ${GEO_NEW_FILE}"

