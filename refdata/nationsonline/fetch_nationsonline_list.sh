#!/bin/sh

#
OPEN_URL=http://www.nationsonline.org/oneworld/IATA_Codes/airport_code_list.htm

POR_HTML_FILE=airport_code_list.htm
POR_TXT_FILE=nationsonline_airport_list.txt
POR_CSV_FILE=nationsonline_airport_list.csv

#
wget ${OPEN_URL}
\mv -f ${POR_HTML_FILE} ${POR_TXT_FILE}

# Cleaning
#\rm -f ${POR_HTML_FILE}

