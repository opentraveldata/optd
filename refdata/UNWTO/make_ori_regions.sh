#!/bin/sh
#
# That script extract information from the UNTWO region
# specification data file.
#

##
# ORI
ORI_DIR=../ORI/

##
# Input: UNTWO regions
UN_RGN_FILENAME=unwto_region_details.tsv
UN_RGN_FILE=${UN_RGN_FILENAME}

##
# Output: ORI regions
ORI_RGN_DET_FILENAME=ori_region_details.csv
ORI_RGN_SUM_FILENAME=ori_regions.csv
#
ORI_RGN_DET_FILE=${ORI_DIR}${ORI_RGN_DET_FILENAME}
ORI_RGN_SUM_FILE=${ORI_DIR}${ORI_RGN_SUM_FILENAME}

##
# Extract the specifications of each region/continent
RGN_MAKER=make_ori_regions.awk
awk -F'\t' -f ${RGN_MAKER} ${UN_RGN_FILE} > ${ORI_RGN_DET_FILE}

##
# Extract just the region names and dump them into the dedicated file
cut -d'^' -f2 ${ORI_RGN_DET_FILE} | grep -v "^User" | grep -v "^Region" | sort -t'^' -k1,1 | uniq > ${ORI_RGN_SUM_FILE}.tmp
grep -v "^UNWTO" ${ORI_RGN_SUM_FILE} | grep -v "^user" > ${ORI_RGN_SUM_FILE}.tmpwountwo
awk -F'^' '{print "UNWTO^" toupper(substr($1, 1, 2)) "^" $1 "^"}' ${ORI_RGN_SUM_FILE}.tmp >> ${ORI_RGN_SUM_FILE}.tmpwountwo
sort -t'^' -k1,2 ${ORI_RGN_SUM_FILE}.tmpwountwo > ${ORI_RGN_SUM_FILE}.tmp
echo "user^region_code^region_name^region_id" > ${ORI_RGN_SUM_FILE}.hdr
cat ${ORI_RGN_SUM_FILE}.hdr ${ORI_RGN_SUM_FILE}.tmp > ${ORI_RGN_SUM_FILE}
\rm -f ${ORI_RGN_SUM_FILE}.tmp ${ORI_RGN_SUM_FILE}.tmpwountwo ${ORI_RGN_SUM_FILE}.hdr

##
# Reporting
echo
echo "Generated '${ORI_RGN_DET_FILE}' and '${ORI_RGN_SUM_FILE}' from '${UN_RGN_FILE}'"
echo

