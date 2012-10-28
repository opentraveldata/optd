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
# Geonames data store
GEO_POR_DATA_DIR=${EXEC_PATH}../geonames/data/por/data/

# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`

##
# Extract airport/city information from the Geonames data file
GEO_POR_FILENAME=allCountries_w_alt.txt
GEO_POR_FILE=${GEO_POR_DATA_DIR}${GEO_POR_FILENAME}
# Generated files
DUMP_FILE_IATA_TVL_FILENAME=por_all_iata_tvl_${SNAPSHOT_DATE}.csv
DUMP_FILE_IATA_CTY_FILENAME=por_all_iata_cty_${SNAPSHOT_DATE}.csv
DUMP_FILE_IATA_ALL_FILENAME=por_all_iata_${SNAPSHOT_DATE}.csv
DUMP_FILE_ICAO_ONLY_FILENAME=por_all_icao_only_${SNAPSHOT_DATE}.csv
DUMP_FILE_NO_CODE_FILENAME=por_all_nocode_${SNAPSHOT_DATE}.csv
DUMP_FILE_NO_ICAO_FILENAME=por_all_noicao_${SNAPSHOT_DATE}.csv
DUMP_FILE_DUP_FILENAME=por_all_dup_iata_${SNAPSHOT_DATE}.csv
#
DUMP_FILE_IATA_TVL=${TMP_DIR}${DUMP_FILE_IATA_TVL_FILENAME}
DUMP_FILE_IATA_CTY=${TMP_DIR}${DUMP_FILE_IATA_CTY_FILENAME}
DUMP_FILE_IATA_ALL=${TMP_DIR}${DUMP_FILE_IATA_ALL_FILENAME}
DUMP_FILE_ICAO_ONLY=${TMP_DIR}${DUMP_FILE_ICAO_ONLY_FILENAME}
DUMP_FILE_NO_CODE=${TMP_DIR}${DUMP_FILE_NO_CODE_FILENAME}
DUMP_FILE_NO_ICAO=${TMP_DIR}${DUMP_FILE_NO_ICAO_FILENAME}
DUMP_FILE_DUP=${TMP_DIR}${DUMP_FILE_DUP_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	echo "  - Input (CSV-formatted) data file: '${GEO_POR_FILE}'"
	echo "  - Generated (CSV-formatted) data files:"
	echo "      + '${DUMP_FILE_IATA_TVL}'"
	echo "      + '${DUMP_FILE_IATA_CTY}'"
	echo "      + '${DUMP_FILE_ICAO_ONLY}'"
	echo "      + '${DUMP_FILE_NO_CODE}'"
	echo "      + '${DUMP_FILE_NO_ICAO}'"
	echo "      + '${DUMP_FILE_DUP}'"
	echo
	exit
fi

##
# 0. Data extraction from the Geonames data file, for travel-related POR
#    and cities.
echo
echo "Extracting travel-related points of reference (POR, i.e., airports, railway stations) and populated place (city) data from the Geonames dump data file."
echo "The '${GEO_POR_FILE}' input data file allows to generate both '${DUMP_FILE_IATA_TVL}' and '${DUMP_FILE_IATA_CTY}' files."
echo "That operation may take several minutes..."
IATA_EXTRACTOR=${EXEC_PATH}extract_por_with_iata_icao.awk
time awk -F'^' -v iata_tvl_file=${DUMP_FILE_IATA_TVL} -v iata_cty_file=${DUMP_FILE_IATA_CTY} -v iata_icaoonly_file=${DUMP_FILE_ICAO_ONLY} -v iata_nocode_file=${DUMP_FILE_NO_CODE} -v iata_noicao_file=${DUMP_FILE_NO_ICAO} -f ${IATA_EXTRACTOR} ${GEO_POR_FILE}
echo "... Done"
echo

##
# Remove the first line (header). Note: that step should now be performed by
# the caller.
#sed -i -e "s/^iata_code\(.\+\)//g" ${DUMP_FILE_IATA_TVL}
#sed -i -e "/^$/d" ${DUMP_FILE_IATA_TVL}

##
# We are now left with only the points of interest containing a non-NULL IATA
# code.

# 1.1. Extract the headers into temporary files
# 1.1.1. For travel-related POR
DUMP_FILE_TVL_HDR=${DUMP_FILE_IATA_TVL}.tmp.tvlhdr
grep "^iata\(.\+\)" ${DUMP_FILE_IATA_TVL} > ${DUMP_FILE_TVL_HDR}
# 1.1.2. For cities
DUMP_FILE_CTY_HDR=${DUMP_FILE_IATA_CTY}.tmp.ctyhdr
grep "^iata\(.\+\)" ${DUMP_FILE_IATA_CTY} > ${DUMP_FILE_CTY_HDR}

# 1.2. Remove the headers
# 1.2.1. For travel-related POR
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_FILE_IATA_TVL}
sed -i -e "/^$/d" ${DUMP_FILE_IATA_TVL}
# 1.2.2. For cities
sed -i -e "s/^iata\(.\+\)//g" ${DUMP_FILE_IATA_CTY}
sed -i -e "/^$/d" ${DUMP_FILE_IATA_CTY}

# 2. Sort the files
DUMP_FILE_TMP=${TMP_DIR}sorted.csv.tmp
# 2.1. Travel-related
sort -t '^' -k1,2 ${DUMP_FILE_IATA_TVL} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE_IATA_TVL}
# 2.2. Cities
sort -t '^' -k1,2 ${DUMP_FILE_IATA_CTY} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE_IATA_CTY}
# 2.2. No ICAO codes
sort -t '^' -k1,2 ${DUMP_FILE_NO_ICAO} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE_NO_ICAO}

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
DUMP_UNIQ_FILE=${DUMP_FILE_IATA_TVL}.tmp.uniq
uniq -w 3 ${DUMP_FILE_IATA_TVL} > ${DUMP_UNIQ_FILE}

# 3.1.2. Create the file with only the duplicated IATA code entries, if any.
DUMP_FILE_DUP_CHECK=${DUMP_FILE_DUP}.tmp.check
comm -23 ${DUMP_FILE_IATA_TVL} ${DUMP_UNIQ_FILE} > ${DUMP_FILE_DUP_CHECK}
sed -i -e "/^$/d" ${DUMP_FILE_DUP_CHECK}

if [ -s ${DUMP_FILE_DUP_CHECK} ]
then
	POR_DUP_IATA_NB=`wc -l ${DUMP_FILE_DUP_CHECK} | cut -d' ' -f1`
	echo
	echo "!!!!!! WARNING !!!!!!!!"
	echo "Geonames has got ${POR_DUP_IATA_NB} duplicated IATA codes (in addition to those of cities of course). To see them, just do:"
	echo "less ${DUMP_FILE_DUP_CHECK}"
	echo "Note: they result of the comparison between '${DUMP_FILE_IATA_TVL}' (all POR) and"
	echo "'${DUMP_UNIQ_FILE}' (duplicated POR have been removed)."
	echo "!!!!!! WARNING !!!!!!!!"
	echo
else
	\rm -f ${DUMP_FILE_DUP_CHECK}
fi

# 3.2. Merge the data files for both POR types (travel-related and cities)
cat ${DUMP_UNIQ_FILE} ${DUMP_FILE_IATA_CTY} > ${DUMP_FILE_IATA_ALL}
sort -t'^' -k1,2 ${DUMP_FILE_IATA_ALL} > ${DUMP_FILE_TMP}
\mv -f ${DUMP_FILE_TMP} ${DUMP_FILE_IATA_ALL}

# 3.3. Re-add the header
cat ${DUMP_FILE_TVL_HDR} ${DUMP_FILE_IATA_ALL} > ${DUMP_FILE_TMP}
sed -e "/^$/d" ${DUMP_FILE_TMP} > ${DUMP_FILE_IATA_ALL}

##
# Clean
if [ "${TMP_DIR}" != "/tmp/por/" ]
then
	\rm -f ${DUMP_FILE_TVL_HDR} ${DUMP_FILE_TMP} ${DUMP_FILE_CTY_HDR}
	\rm -f ${DUMP_UNIQ_FILE} ${DUMP_FILE_IATA_CTY_TMP}
fi

