#!/bin/sh

##
# Input files
GEO_FILE_1=dump_from_geonames.csv
GEO_FILE_1_MISSING=${GEO_FILE_1}.missing
GEO_FILE_1_TMP=${GEO_FILE_1}.tmp
RFD_FILE=dump_from_crb_city.csv
PR_FILE=../ORI/ref_airport_pageranked.csv

##
# Output files
GEO_FILE_2=por_in_iata_but_missing_from_geonames.csv
GEO_FILE_2_PR=pageranked_${GEO_FILE_2}
SORTED_PR_FILE=sorted_ref_airport_pageranked.csv

##
# Headers
HDR_1="code^ticketing_name^detailed_name^teleticketing_name^extended_name^city_name^rel_city_code^is_airport^state_code^rel_country_code^rel_region_code^rel_continent_code^rel_time_zone_grp^latitude^longitude^numeric_code^is_commercial^location_type"
HDR_2="${HDR_1}^page_rank"

##
#
if [ ! -f ${GEO_FILE_1_MISSING} ]
then
	echo
	echo "The ${GEO_FILE_1_MISSING} file is missing."
	echo "Hint: launch the ./update_airports_csv_after_getting_geonames_iata_dump.sh script."
	echo
	exit -1
fi
#
if [ ! -f ${RFD_FILE} ]
then
	echo
	echo "The ${RFD_FILE} file is missing."
	echo "Hint: copy ${RFD_FILE} from the (private) DataAnalysis project."
	echo
	exit -1
fi

##
# Extract the header into a temporary file
RFD_FILE_HEADER=${RFD_FILE}.tmp.hdr
grep "^code\(.\+\)" ${RFD_FILE} > ${RFD_FILE_HEADER}

# Remove the header
sed -i -e "s/^code\(.\+\)//g" ${RFD_FILE}
sed -i -e "/^$/d" ${RFD_FILE}

##
# Extract only the IATA code from the file
cut -d'^' -f1 ${GEO_FILE_1_MISSING} > ${GEO_FILE_1_TMP}
\mv -f ${GEO_FILE_1_TMP} ${GEO_FILE_1_MISSING}

##
# Check that all the POR are in RFD.
GEO_COMB_FILE=${GEO_FILE_1_MISSING}.withrfd
CUT_GEO_COMB_FILE=${GEO_COMB_FILE}.cut
join -t'^' -a 2 ${RFD_FILE} ${GEO_FILE_1_MISSING} > ${GEO_COMB_FILE}
awk -F'^' '{if (NF != 18) {printf ($0 "\n")}}' ${GEO_COMB_FILE} > ${CUT_GEO_COMB_FILE}
# If there are any non-RFD entries, suggest to remove them.
NB_NON_RFD_ROWS=`wc -l ${CUT_GEO_COMB_FILE} | cut -d' ' -f1`
if [ ${NB_NON_RFD_ROWS} -gt 0 ]
then
	echo
	echo "${NB_NON_RFD_ROWS} POR are not in RFD, but present in the ${GEO_FILE_1_MISSING} file. To see them:"
	echo "less ${CUT_GEO_COMB_FILE}"
	echo "Remove those entries from the ${GEO_FILE_1_MISSING} file:"
	echo "vi ${GEO_FILE_1_MISSING}"
	echo
	exit -1
fi

##
# Generate the file for Geonames
join -t'^' -a 2 ${RFD_FILE} ${GEO_FILE_1_MISSING} > ${GEO_FILE_2}
NB_ROWS=`wc -l ${GEO_FILE_2} | cut -d' ' -f1`

##
# Generate a version with the PageRanked POR
sort -t'^' -k1,1 ${PR_FILE} > ${SORTED_PR_FILE}
join -t'^' -a 1 ${GEO_FILE_2} ${SORTED_PR_FILE} > ${GEO_FILE_1_TMP}
awk -F'^' '{printf ($0); if (NF == 18) {printf ("^0.01\n")} else {printf ("\n")}}' ${GEO_FILE_1_TMP} > ${GEO_FILE_2_PR}
sort -t'^' -nrk19,19 ${GEO_FILE_2_PR} > ${GEO_FILE_1_TMP}
\mv -f ${GEO_FILE_1_TMP} ${GEO_FILE_2_PR}

##
# Re-add the headers
cat ${RFD_FILE_HEADER} ${GEO_FILE_2} > ${GEO_FILE_1_TMP}
\mv -f ${GEO_FILE_1_TMP} ${GEO_FILE_2}
\rm -f ${GEO_FILE_2}.hdr

echo "${HDR_2}" > ${GEO_FILE_2}.hdr
cat ${GEO_FILE_2}.hdr ${GEO_FILE_2_PR} > ${GEO_FILE_1_TMP}
\mv -f ${GEO_FILE_1_TMP} ${GEO_FILE_2_PR}
\rm -f ${GEO_FILE_2}.hdr

##
# Reporting
echo
echo "Reporting"
echo "---------"
echo "Both the ${GEO_FILE_2} and ${GEO_FILE_2_PR} files have been generated from ${RFD_FILE} and ${GEO_FILE_1_MISSING}."
echo "${NB_ROWS} rows are in RFD, but missing from Geonames."
echo "gzip ${GEO_FILE_2} ${GEO_FILE_2_PR}"
echo
