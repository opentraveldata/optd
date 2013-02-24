#!/bin/bash
#
# That Bash script extracts data from the 'allCountries_w_alt.txt'
# Geonames-derived data file and exports them into internal
# standard-formatted data files.
#
# See ../geonames/data/por/admin/aggregateGeonamesPor.sh for more details on
# the way to derive that file from Geonames original data files.
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
# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`

##
# Retrieve the latest schedule file
POR_FILE_PFX1=por_all_iata
POR_FILE_PFX2=por_all_icao_only
POR_FILE_PFX3=por_all_nocode
POR_FILE_PFX4=por_all_noicao
LATEST_EXTRACT_DATE=`ls ${EXEC_PATH}/${POR_FILE_PFX1}_????????.csv 2> /dev/null`
if [ "${LATEST_EXTRACT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${LATEST_EXTRACT_DATE}; do echo > /dev/null; done
	LATEST_EXTRACT_DATE=`echo ${myfile} | sed -e "s/${POR_FILE_PFX1}_\([0-9]\+\)\.csv/\1/" | xargs basename`
fi
if [ "${LATEST_EXTRACT_DATE}" != "" ]
then
	LATEST_EXTRACT_DATE_HUMAN=`date -d ${LATEST_EXTRACT_DATE}`
fi
if [ "${LATEST_EXTRACT_DATE}" != "" \
	-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
then
	LATEST_DUMP_IATA_ALL_FILENAME=${POR_FILE_PFX1}_${LATEST_EXTRACT_DATE}.csv
	LATEST_DUMP_ICAO_ONLY_FILENAME=${POR_FILE_PFX2}_${LATEST_EXTRACT_DATE}.csv
	LATEST_DUMP_NO_CODE_FILENAME=${POR_FILE_PFX3}_${LATEST_EXTRACT_DATE}.csv
	LATEST_DUMP_NO_ICAO_FILENAME=${POR_FILE_PFX4}_${LATEST_EXTRACT_DATE}.csv
fi

##
# Geonames data store
GEO_POR_DATA_DIR=${EXEC_PATH}../geonames/data/por/data/

##
# ORI directory
ORI_DIR=${EXEC_PATH}../ORI/


##
# Extract airport/city information from the Geonames data file
GEO_POR_FILENAME=allCountries_w_alt.txt
GEO_CTY_FILENAME=countryInfo.txt
GEO_CNT_FILENAME=continentCodes.txt
#
GEO_POR_FILE=${GEO_POR_DATA_DIR}${GEO_POR_FILENAME}
GEO_CTY_FILE=${GEO_POR_DATA_DIR}${GEO_CTY_FILENAME}
GEO_CNT_FILE=${GEO_POR_DATA_DIR}${GEO_CNT_FILENAME}

##
# Generated files
DUMP_IATA_TVL_FILENAME=${POR_FILE_PFX1}_tvl_${SNAPSHOT_DATE}.csv
DUMP_IATA_CTY_FILENAME=${POR_FILE_PFX1}_cty_${SNAPSHOT_DATE}.csv
DUMP_IATA_ALL_FILENAME=${POR_FILE_PFX1}_${SNAPSHOT_DATE}.csv
DUMP_ICAO_ONLY_FILENAME=${POR_FILE_PFX2}_${SNAPSHOT_DATE}.csv
DUMP_NO_CODE_FILENAME=${POR_FILE_PFX3}_${SNAPSHOT_DATE}.csv
DUMP_NO_ICAO_FILENAME=${POR_FILE_PFX4}_${SNAPSHOT_DATE}.csv
DUMP_DUP_FILENAME=por_all_dup_iata_${SNAPSHOT_DATE}.csv
# Light version of the country-related time-zones
ORI_TZ_FILENAME=ori_tz_light.csv
# Mapping between countries and continents
ORI_CNT_FILENAME=ori_cont.csv

#
DUMP_IATA_TVL_FILE=${TMP_DIR}${DUMP_IATA_TVL_FILENAME}
DUMP_FILE_TVL_HDR=${DUMP_IATA_TVL_FILE}.tmp.tvlhdr
DUMP_UNIQ_FILE=${DUMP_IATA_TVL_FILE}.tmp.uniq
DUMP_IATA_CTY_FILE=${TMP_DIR}${DUMP_IATA_CTY_FILENAME}
DUMP_FILE_CTY_HDR=${DUMP_IATA_CTY_FILE}.tmp.ctyhdr
DUMP_IATA_ALL_FILE=${TMP_DIR}${DUMP_IATA_ALL_FILENAME}
DUMP_ICAO_ONLY_FILE=${TMP_DIR}${DUMP_ICAO_ONLY_FILENAME}
DUMP_NO_CODE_FILE=${TMP_DIR}${DUMP_NO_CODE_FILENAME}
DUMP_NO_ICAO_FILE=${TMP_DIR}${DUMP_NO_ICAO_FILENAME}
DUMP_DUP_FILE=${TMP_DIR}${DUMP_DUP_FILENAME}
DUMP_FILE_TMP=${TMP_DIR}sorted.csv.tmp
# ORI-related data files
ORI_TZ_FILE=${ORI_DIR}${ORI_TZ_FILENAME}
ORI_CNT_FILE=${ORI_DIR}${ORI_CNT_FILENAME}
ORI_CNT_FILE_TMP=${TMP_DIR}${ORI_CNT_FILENAME}.tmp
ORI_CNT_FILE_TMP_SORTED=${TMP_DIR}${ORI_CNT_FILENAME}.tmp.sorted
ORI_CNT_FILE_HDR=${TMP_DIR}${ORI_CNT_FILENAME}.tmp.hdr

##
# Latest snapshot data files
LATEST_DUMP_IATA_ALL_FILE=${TMP_DIR}${LATEST_DUMP_IATA_ALL_FILENAME}
LATEST_DUMP_ICAO_ONLY_FILE=${TMP_DIR}${LATEST_DUMP_ICAO_ONLY_FILENAME}
LATEST_DUMP_NO_CODE_FILE=${TMP_DIR}${LATEST_DUMP_NO_CODE_FILENAME}
LATEST_DUMP_NO_ICAO_FILE=${TMP_DIR}${LATEST_DUMP_NO_ICAO_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	if [ "${LATEST_EXTRACT_DATE}" != "" \
		-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
	then
		echo "  - Latest extraction date: '${LATEST_EXTRACT_DATE}' (${LATEST_EXTRACT_DATE_HUMAN})"
	fi
	echo "  - Geonames input data files from '${GEO_POR_DATA_DIR}':"
	echo "      + Detailed POR entry data file (~9 millions): '${GEO_POR_FILE}'"
	echo "      + Detailed country information data file: '${GEO_CTY_FILE}'"
	echo "      + Continent information data file: '${GEO_CONT_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data files in '${EXEC_PATH}':"
	echo "      + '${DUMP_IATA_ALL_FILE}'"
	echo "      + '${DUMP_IATA_TVL_FILE}'"
	echo "      + '${DUMP_IATA_CTY_FILE}'"
	echo "      + '${DUMP_ICAO_ONLY_FILE}'"
	echo "      + '${DUMP_NO_CODE_FILE}'"
	echo "      + '${DUMP_NO_ICAO_FILE}'"
	echo "      + '${DUMP_DUP_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data files in '${ORI_DIR}':"
	echo "      + '${ORI_TZ_FILE}' (maybe sometimes in the future)"
	echo "      + '${ORI_CNT_FILE}'"
	echo
	exit
fi

##
#
if [ "$1" = "--clean" ]
	then
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${DUMP_FILE_TVL_HDR} ${DUMP_FILE_CTY_HDR}
		\rm -f ${DUMP_FILE_TMP} ${DUMP_UNIQ_FILE}
		\rm -f ${DUMP_IATA_TVL_FILE} ${DUMP_IATA_CTY_FILE}
		\rm -f ${ORI_CNT_FILE_HDR} ${ORI_CNT_FILE_TMP}
		\rm -f ${ORI_CNT_FILE_TMP_SORTED}
	fi
	exit
fi

##
# 0. Data extraction from the Geonames data file

# 0.1. For country-related information (continent, for now)
echo
echo "Extracting country-related information from '${GEO_CTY_FILE}'"
CONT_EXTRACTOR=${EXEC_PATH}extract_continent_mapping.awk
awk -F'\t' -f ${CONT_EXTRACTOR} ${GEO_CNT_FILE} ${GEO_CTY_FILE} \
	> ${ORI_CNT_FILE_TMP}
# Extract and remove the header
grep "^country_code\(.\+\)" ${ORI_CNT_FILE_TMP} > ${ORI_CNT_FILE_HDR}
sed -i -e "s/^country_code\(.\+\)//g" ${ORI_CNT_FILE_TMP}
sed -i -e "/^$/d" ${ORI_CNT_FILE_TMP}
# Sort by country code
sort -t'^' -k1,1 ${ORI_CNT_FILE_TMP} > ${ORI_CNT_FILE_TMP_SORTED}
# Re-add the header
cat ${ORI_CNT_FILE_HDR} ${ORI_CNT_FILE_TMP_SORTED} > ${ORI_CNT_FILE_TMP}
sed -e "/^$/d" ${ORI_CNT_FILE_TMP} > ${ORI_CNT_FILE}

# 0.2. For travel-related POR and cities.
echo
echo "Extracting travel-related points of reference (POR, i.e., airports, railway stations)"
echo "and populated place (city) data from the Geonames dump data file."
echo "The '${GEO_POR_FILE}' input data file allows to generate both '${DUMP_IATA_TVL_FILE}' and '${DUMP_IATA_CTY_FILE}' files."
echo "That operation may take several minutes..."
IATA_EXTRACTOR=${EXEC_PATH}extract_por_with_iata_icao.awk
time awk -F'^' \
	-v iata_tvl_file=${DUMP_IATA_TVL_FILE} \
	-v iata_cty_file=${DUMP_IATA_CTY_FILE} \
	-v iata_icaoonly_file=${DUMP_ICAO_ONLY_FILE} \
	-v iata_nocode_file=${DUMP_NO_CODE_FILE} \
	-v iata_noicao_file=${DUMP_NO_ICAO_FILE} \
	-f ${IATA_EXTRACTOR} ${GEO_POR_FILE}
echo "... Done"
echo

##
# Remove the first line (header). Note: that step should now be performed by
# the caller.
#sed -i -e "s/^iata_code\(.\+\)//g" ${DUMP_IATA_TVL_FILE}
#sed -i -e "/^$/d" ${DUMP_IATA_TVL_FILE}

##
# We are now left with only the points of interest containing a non-NULL IATA
# code.

# 1.1. Extract the headers into temporary files
# 1.1.1. For travel-related POR
grep "^iata\(.\+\)" ${DUMP_IATA_TVL_FILE} > ${DUMP_FILE_TVL_HDR}
# 1.1.2. For cities
grep "^iata\(.\+\)" ${DUMP_IATA_CTY_FILE} > ${DUMP_FILE_CTY_HDR}

# 1.2. Remove the headers
# 1.2.1. For travel-related POR
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_IATA_TVL_FILE}
sed -i -e "/^$/d" ${DUMP_IATA_TVL_FILE}
# 1.2.2. For cities
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_IATA_CTY_FILE}
sed -i -e "/^$/d" ${DUMP_IATA_CTY_FILE}

# 2. Sort the files
# 2.1. Travel-related
sort -t '^' -k1,2 ${DUMP_IATA_TVL_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_IATA_TVL_FILE}
# 2.2. Cities
sort -t '^' -k1,2 ${DUMP_IATA_CTY_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_IATA_CTY_FILE}
# 2.2. No ICAO codes
sort -t '^' -k1,2 ${DUMP_NO_ICAO_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_NO_ICAO_FILE}

# 3.1. Spot the (potential) remaining entries having duplicated IATA codes.
#      Here, only the airport entries having duplicated IATA codes are spotted.
#      That case may typically appear when someone, in Geonames, has mistakenly
#      set the IATA code (say ACQ; that airport is Waseca Municpal Airport and
#      its ICAO code is KACQ) in place of the FAA code (indeed, ACQ is the FAA
#      code, not the IATA code).
#
#      With the uniq command, all the entries having a duplicated IATA code are
#      deleted. Then, the original file (with potential duplicated entries) is
#      compared with the de-duplicated file: the differences are the duplicated
#      entries.
#
# 3.1.1. Create the file with no duplicated IATA code.
uniq -w 3 ${DUMP_IATA_TVL_FILE} > ${DUMP_UNIQ_FILE}

# 3.1.2. Create the file with only the duplicated IATA code entries, if any.
DUMP_DUP_FILE_CHECK=${DUMP_DUP_FILE}.tmp.check
comm -23 ${DUMP_IATA_TVL_FILE} ${DUMP_UNIQ_FILE} > ${DUMP_DUP_FILE_CHECK}
sed -i -e "/^$/d" ${DUMP_DUP_FILE_CHECK}

if [ -s ${DUMP_DUP_FILE_CHECK} ]
then
	POR_DUP_IATA_NB=`wc -l ${DUMP_DUP_FILE_CHECK} | cut -d' ' -f1`
	echo
	echo "!!!!!! WARNING !!!!!!!!"
	echo "Geonames has got ${POR_DUP_IATA_NB} duplicated IATA codes (in addition to those of cities of course). To see them, just do:"
	echo "less ${DUMP_DUP_FILE_CHECK}"
	echo "Note: they result of the comparison between '${DUMP_IATA_TVL_FILE}' (all POR) and"
	echo "'${DUMP_UNIQ_FILE}' (duplicated POR have been removed)."
	echo "!!!!!! WARNING !!!!!!!!"
	echo
else
	\rm -f ${DUMP_DUP_FILE_CHECK}
fi

# 3.2. Merge the data files for both POR types (travel-related and cities)
cat ${DUMP_UNIQ_FILE} ${DUMP_IATA_CTY_FILE} > ${DUMP_IATA_ALL_FILE}
sort -t'^' -k1,2 ${DUMP_IATA_ALL_FILE} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_IATA_ALL_FILE}

# 3.3. Re-add the header
cat ${DUMP_FILE_TVL_HDR} ${DUMP_IATA_ALL_FILE} > ${DUMP_FILE_TMP}
sed -e "/^$/d" ${DUMP_FILE_TMP} > ${DUMP_IATA_ALL_FILE}


##
# Reporting
#
echo
echo "Reporting step"
echo "--------------"
echo
echo "From the '${GEO_POR_FILE}' input data file, the following data files have been derived:"
echo " + '${DUMP_IATA_ALL_FILE}'"
echo " + '${DUMP_ICAO_ONLY_FILE}'"
echo " + '${DUMP_NO_CODE_FILE}'"
echo " + '${DUMP_NO_ICAO_FILE}'"
echo " + '${DUMP_DUP_FILE}'"
echo
echo
echo "Other temporary files have been generated. Just issue the following command to delete them:"
echo "$0 --clean"
echo
echo "Following steps:"
echo "----------------"
echo "After having checked that the updates brought by Geonames are legitimate and not disruptive, i.e.:"
if [ "${LATEST_EXTRACT_DATE}" != "" \
	-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
then
	echo "diff -c ${LATEST_DUMP_IATA_ALL_FILE} ${DUMP_IATA_ALL_FILE} | less"
	echo "diff -c ${LATEST_DUMP_ICAO_ONLY_FILE} ${DUMP_ICAO_ONLY_FILE} | less"
	echo "diff -c ${LATEST_DUMP_NO_CODE_FILE} ${DUMP_NO_CODE_FILE} | less"
	echo "diff -c ${LATEST_DUMP_NO_ICAO_FILE} ${DUMP_NO_ICAO_FILE} | less"
	echo "mkdir -p archives && bzip2 *_${LATEST_EXTRACT_DATE}.csv && mv *_${LATEST_EXTRACT_DATE}.csv.bz2 archives"
fi
echo
echo "The consolidated Geonames data file (dump_from_geonames.csv) may be generated:"
echo "${EXEC_PATH}preprepare_geonames_dump_file.sh"
echo
echo

