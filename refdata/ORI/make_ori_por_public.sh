#!/bin/bash

# Create the public version of the ORI-maintained list of POR, from:
# - best_coordinates_known_so_far.csv
# - dump_from_geonames.csv
# - dump_from_crb_city.csv
#
# => ori_por_public.csv
#

##
#
TOOLS_DIR=../tools/

##
# Initial
ORI_POR_FILE=best_coordinates_known_so_far.csv
ORI_ONLY_POR_FILE=ori_por_non_iata.csv
#
GEONAME_FILENAME=dump_from_geonames.csv
RFD_FILENAME=dump_from_crb_city.csv
#
GEONAME_FILE=${TOOLS_DIR}${GEONAME_FILENAME}
RFD_FILE=${TOOLS_DIR}${RFD_FILENAME}

# Target
ORI_POR_PUBLIC_FILE=ori_por_public.csv
ORI_ONLY_POR_NEW_FILE=${ORI_ONLY_POR_FILE}.new

# Temporary
ORI_POR_WITH_GEO=${ORI_POR_FILE}.withgeo
ORI_POR_WITH_GEORFD=${ORI_POR_FILE}.withgeorfd
ORI_POR_WITH_GEORFDALT=${ORI_POR_FILE}.withgeorfdalt
RFD_SORTED_FILE=sorted_${RFD_FILENAME}
RFD_CUT_SORTED_FILE=cut_sorted_${RFD_FILENAME}
#
GEONAME_SORTED_FILENAME=sorted_${GEONAME_FILENAME}
GEONAME_CUT_SORTED_FILENAME=cut_sorted_${GEONAME_FILENAME}
#
GEONAME_SORTED_FILE=${TOOLS_DIR}${GEONAME_SORTED_FILENAME}
GEONAME_CUT_SORTED_FILE=${TOOLS_DIR}${GEONAME_CUT_SORTED_FILENAME}

##
#
if [ "$1" = "--clean" ];
then
	\rm -f ${ORI_POR_WITH_GEO} ${ORI_ONLY_POR_NEW_FILE} \
		${ORI_POR_WITH_GEORFD} ${ORI_POR_WITH_GEORFDALT} \
		${GEONAME_SORTED_FILE} ${GEONAME_CUT_SORTED_FILE} \
		${RFD_SORTED_FILE} ${RFD_CUT_SORTED_FILE}
	exit
fi

##
# Preparation
pushd ${TOOLS_DIR}
bash prepare_geonames_dump_file.sh
popd
bash prepare_rfd_dump_file.sh

##
#
if [ ! -f ${GEONAME_SORTED_FILE} ]
then
	echo
	echo "The '${GEONAME_SORTED_FILE}' file does not exist."
	echo
	exit -1
fi
if [ ! -f ${RFD_SORTED_FILE} ]
then
	echo
	echo "The '${RFD_SORTED_FILE}' file does not exist."
	echo
	exit -1
fi

##
# Save the extra alternate names (from field #26 onwards)
GEONAME_FILE_TMP=${GEONAME_FILE}.alt
cut -d'^' -f1,26- ${GEONAME_SORTED_FILE} > ${GEONAME_FILE_TMP}
# Remove the extra alternate names (see the line above)
cut -d'^' -f1-25 ${GEONAME_SORTED_FILE} > ${GEONAME_CUT_SORTED_FILE}

##
# Aggregate all the data sources into a single file
#
# ${ORI_POR_FILE} (best_coordinates_known_so_far.csv) and
# ${GEONAME_CUT_SORTED_FILE} (../tools/cut_sorted_dump_from_geonames.csv) are joined
# on the IATA code alone:
join -t'^' -a 1 -1 2 -2 1 ${ORI_POR_FILE} ${GEONAME_CUT_SORTED_FILE} > ${ORI_POR_WITH_GEO}

# ${ORI_POR_WITH_GEO} (best_coordinates_known_so_far.csv.withgeo) and
# ${GEONAME_CUT_SORTED_FILE} (sorted_dump_from_crb_city.csv) are joined on the
# primary key (i.e., IATA code + location type):
join -t'^' -a 1 -1 2 -2 1 ${ORI_POR_WITH_GEO} ${RFD_SORTED_FILE} > ${ORI_POR_WITH_GEORFD}

# ${ORI_POR_WITH_GEORFD} (best_coordinates_known_so_far.csv.withgeorfd) and
# ${GEONAME_FILE_TMP} (../tools/dump_from_geonames.csv.alt) are joined on the
# IATA code alone:
join -t'^' -a 1 -1 2 -2 1 ${ORI_POR_WITH_GEORFD} ${GEONAME_FILE_TMP} > ${ORI_POR_WITH_GEORFDALT}

##
# Suppress the redundancies. See ${REDUCER} for more details and samples.
REDUCER=make_ori_por_public.awk
awk -F'^' -f ${REDUCER} ${ORI_POR_WITH_GEORFDALT} > ${ORI_POR_PUBLIC_FILE}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${ORI_POR_FILE} ${ORI_POR_WITH_GEO} ${ORI_POR_WITH_GEORFD} ${ORI_POR_WITH_GEORFDALT}"
if [ -f ${ORI_ONLY_POR_NEW_FILE} ]
then
	NB_LINES_ORI_ONLY=`wc -l ${ORI_ONLY_POR_NEW_FILE}`
	echo
	echo "See also the '${ORI_ONLY_POR_NEW_FILE}' file, which contains ${NB_LINES_ORI_ONLY} lines:"
	echo "less ${ORI_ONLY_POR_NEW_FILE}"
fi
echo
