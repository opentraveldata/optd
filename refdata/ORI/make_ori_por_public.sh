#!/bin/bash

# Create the public version of the ORI-maintained list of POR, from:
# - best_coordinates_known_so_far.csv
# - dump_from_geonames.csv
# - dump_from_crb_city.csv
#
# => ori_por_public.csv
#

##
# Initial
ORI_POR_FILE=best_coordinates_known_so_far.csv
GEONAME_FILE=dump_from_geonames.csv
RFD_FILE=dump_from_crb_city.csv
ORI_ONLY_POR_FILE=ori_por_non_iata.csv

# Target
ORI_POR_PUBLIC_FILE=ori_por_public.csv
ORI_ONLY_POR_NEW_FILE=${ORI_ONLY_POR_FILE}.new

# Temporary
ORI_POR_WITH_GEO=${ORI_POR_FILE}.withgeo
ORI_POR_WITH_GEORFD=${ORI_POR_FILE}.withgeorfd
GEONAME_SORTED_FILE=sorted_${GEONAME_FILE}
RFD_SORTED_FILE=sorted_${RFD_FILE}

##
# Preparation
bash prepare_geonames_dump_file.sh
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
# Aggregate all the data sources into a single file
join -t'^' -a 1 ${ORI_POR_FILE} ${GEONAME_SORTED_FILE} > ${ORI_POR_WITH_GEO}
join -t'^' -a 1 ${ORI_POR_WITH_GEO} ${RFD_SORTED_FILE} > ${ORI_POR_WITH_GEORFD}

##
# Suppress the redundancies. See ${REDUCER} for more details and samples.
REDUCER=make_ori_por_public.awk
awk -F'^' -f ${REDUCER} ${ORI_POR_WITH_GEORFD} > ${ORI_POR_PUBLIC_FILE}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${ORI_POR_FILE} ${ORI_POR_WITH_GEO} ${ORI_POR_WITH_GEORFD}"
echo
echo "See also the '${ORI_ONLY_POR_NEW_FILE}' file: less ${ORI_ONLY_POR_NEW_FILE}"
echo
