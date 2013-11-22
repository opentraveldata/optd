#!/bin/sh

# ORI
ORI_DIR=../ORI/

# Input: UNTWO regions
UN_RGN_FILENAME=unwto_regions.tsv
UN_RGN_FILE=${UN_RGN_FILENAME}

# Output: ORI regions
ORI_RGN_FILENAME=ori_regions.csv
ORI_RGN_FILE=${ORI_DIR}${ORI_RGN_FILENAME}

#
RGN_MAKER=make_ori_regions.awk
awk -F'\t' -f ${RGN_MAKER} ${UN_RGN_FILE} > ${ORI_RGN_FILE}

# Reporting
echo
echo "Generated '${ORI_RGN_FILE}' from '${UN_RGN_FILE}'"
echo

