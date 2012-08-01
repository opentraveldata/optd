#!/bin/bash

##
# That Shell script, helped by AWK, concatenates the alternate name details,
# and add them back to the line of details for every Geoname POR.
#
# There are two input files, normally 'alternateNames.txt' for the
# alternate name details, and 'allCountries.txt' for the details of every
# Geoname POR (Point Of Reference).

# Data directory
DATA_DIR=../data/

# Input data files
GEO_POR_FILENAME=allCountries.txt
GEO_POR_ALT_FILENAME=alternateNames.txt
#
GEO_POR_FILE=${DATA_DIR}${GEO_POR_FILENAME}
GEO_POR_ALT_FILE=${DATA_DIR}${GEO_POR_ALT_FILENAME}

# Output data file
GEO_POR_CONC_FILENAME=allCountries_w_alt.txt
GEO_POR_CONC_FILE=${DATA_DIR}${GEO_POR_CONC_FILENAME}

# Reference details for the Nice airport (IATA code: NCE, Geoname ID: 6299418)
NCE_POR_REF="6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^43.66272^7.20787^S^AIRP^FR^^B8^06^062^06088^0^3^-9999^Europe/Paris^2012-06-30^1886047^icao^LFMN^^^^^1888981^iata^NCE^^^^^1969714^de^Flughafen Nizza^^^^^1969715^en^Nice Côte d'Azur International Airport^^^^^2187822^es^Niza Aeropuerto^1^1^^^3032536^link^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^^^^^5713800^fr^Aéroport de Nice Côte d'Azur^^^^^7717894^en^Nice Airport^^1^^"

##
# Check that the line format has not been changed and/or for outliers.
#
# Note that, contrary to awk, grep takes \t as a mere 't' (\t is not a POSIX
# standard). So, the \t of awk must be replaced by actual TAB characters,
# which may be entered thanks to the <CTRL-q TAB> sequence in Emacs and
# <CTRL-v TAB> sequence in the Shell command-line.
#
# Test 1 - Count the lines with the given regex
# The following two commands:
# grep "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_POR_FILE} | wc -l
# grep -nv "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_POR_ALT_FILE} | wc -l
# should give the same result as:
# wc -l ${GEO_POR_FILE} ${GEO_POR_ALT_FILE}
#
# Test 2 - Output the lines not matching the regex
# The following commands should yield empty results:
# grep -nv "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_POR_FILE}
# grep -nv "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_POR_ALT_FILE}
#
# Test 3 - Output the lines of the other file matching the regex
# The following commands should yield empty results:
# grep -n "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_POR_ALT_FILE}
# grep -n "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_POR_FILE}

##
# Concatenate the alternate name details, and add them back to the line of
# details for every Geoname POR.
AGGREGATOR=aggregateGeonamesPor.awk
echo
echo "Aggregating '${GEO_POR_ALT_FILE}' and '${GEO_POR_FILE}' input files..."
time awk -F'\t' -f ${AGGREGATOR} ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} > ${GEO_POR_CONC_FILE}
echo "... done"
echo

##
# Reporting
echo
echo "The '${GEO_POR_CONC_FILE}' file has been generated from both the '${GEO_POR_ALT_FILE}' and '${GEO_POR_FILE}' input files."
echo

# Check #1
echo "Simple check #1 (the size of the output file should be roughly equal to the sum of the sizes of the input files): ls -lh ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}"
ls -lh ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}
echo

# Check #2
echo "Simple check #2: wc -l ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}"
time wc -l ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}
echo

# Check #3
echo "Simple check #3: grep -n \"^6299418\" ${GEO_POR_CONC_FILE}"
NCE_POR=`grep "^6299418" ${GEO_POR_CONC_FILE}`
if [ "${NCE_POR}" = "${NCE_POR_REF}" ]
then
	echo "	Strings are equal"
else
	echo "	Strings are not equal. Someone may have added some alternate names?"
	echo "	Compare (result of grep -n \"^6299418\" ${GEO_POR_CONC_FILE}):"
	echo "	${NCE_POR}"
	echo "	to (reference):"
	echo "	${NCE_POR_REF}"
fi
echo

#
echo
