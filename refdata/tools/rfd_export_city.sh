#!/bin/sh

if [ -z "${TMP}" ];
then
	TMP=/tmp
fi

SQL_FILE=${TMP}/rfd_city.sql
CSV_FILE=${TMP}/rfd_city.csv

# First, create the SQL script
rm -f ${SQL_FILE}
cat > ${SQL_FILE} << __EOF
--
set head off

--
-- crb_city
--
select code || ',' || extended_name || ',' || rel_city_code || ',' || latitude || ',' || longitude
from crb_city;

exit;
__EOF

sqlplus / @${SQL_FILE} | grep -v "^$" | grep -E "^[A-Z][A-Z][A-Z]," > ${CSV_FILE}

rm -f ${SQL_FILE}

echo
echo "The exported CSV file is ${CSV_FILE}"
echo "less ${CSV_FILE}"
echo

