#!/bin/sh

#
mkdir -p tmp

#
OND_FILE="tmp/ond.csv"
OND_ORG_SORTED_FILE="tmp/ond_org_sorted.csv"
OND_DES_SORTED_FILE="tmp/ond_des_sorted.csv"
OND_ORG_COORD_FILE="tmp/ond_org_coord.csv"
OND_FULL_FILE="tmp/ond_full.csv"
#
AIRPORT_DETAILS_FILE="../ORI/ORI_Simple_Airports_Database_Table.csv"
TMP_AIRPORT_COORD_FILE="tmp/airport_coord.csv"

# Extract the coordinates from the airport details file
cut -d',' -f '1 12 13' ${AIRPORT_DETAILS_FILE} | sed -e 's/,/^/g' > ${TMP_AIRPORT_COORD_FILE}

# Sort the O&D file by origin
sort -t'^' -k 1 ${OND_FILE} > ${OND_ORG_SORTED_FILE}

# Add the coordinates for the origin
join -t'^' -i -1 1 -2 1 ${TMP_AIRPORT_COORD_FILE} ${OND_ORG_SORTED_FILE} > ${OND_ORG_COORD_FILE}

sort -t'^' -k 4 ${OND_ORG_COORD_FILE} > ${OND_DES_SORTED_FILE}

join -t'^' -i -1 1 -2 4 ${TMP_AIRPORT_COORD_FILE} ${OND_DES_SORTED_FILE} > ${OND_FULL_FILE}
