#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo "Usage: $0 [<Place's latitude> [<Place's longitude> [<Tolerance> [<Database Server Hostname> [<Database Server Port>]]]]]"
	echo ""
	exit -1
fi

##
# Check whether the first parameter is an airport/city or a latitude
PARAM_AS_CITY=`echo "$1" | sed -e 's/\([a-zA-Z]*\)\([0-9\.]*\).*/\1/'`
PARAM_AS_LAT=`echo "$1" | sed -e 's/\([a-zA-Z]*\)\([0-9\.]*\).*/\2/'`

##
# City/airport of the place, from which the coordinates will be derived
if [ "${PARAM_AS_CITY}" != "" ];
then
	PL_CODE="$1"
fi


##
# Latitude of the place
PL_LAT="43.6"
if [ "${PARAM_AS_LAT}" != "" ];
then
	PL_LAT="$1"

  # Tolerance on the place specification (in the same unit as latitude
  # and longitude)
  PL_TOL="4.0"
  if [ "$2" != "" ];
  then
    PL_TOL="$2"
  fi
fi

# Longitude of the place
PL_LON="6.9"
if [ "$2" != "" ];
then
  PL_LON="$2"

  # Tolerance on the place specification (in the same unit as latitude
  # and longitude)
  PL_TOL="4.0"
  if [ "$3" != "" ];
  then
    PL_TOL="$3"
  fi
fi

# Database Server Hostname
DB_HOST="localhost"
if [ "$4" != "" ];
then
	DB_HOST="$4"
fi

# Database Server Port
DB_PORT="3306"
if [ "$5" != "" ];
then
	DB_PORT="$5"
fi

# Database User
DB_USER="geo"

# Database Password
DB_PASSWD="geo"

# Database Name
DB_NAME="geo_geonames"

# Specify the SQL request
GET_AIRPORT_COORDINATES_REQUEST="
select latitude, longitude from ref_place_details where code = '${PL_CODE}'"

if [ "${PL_CODE}" != "" ];
then
    echo "Get the ${PL_CODE} place coordinates:"
    PL_COORD=`mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "${GET_AIRPORT_COORDINATES_REQUEST}" | grep -v latitude`
    echo "${PL_CODE} => ${PL_COORD}"
    PL_LAT=`echo "${PL_COORD}" | sed -e 's/\([0-9\.-]*\)\B\([0-9\.-]*\)/\1/'`
    PL_LON=`echo "${PL_COORD}" | sed -e 's/\([0-9\.-]*\)\B\([0-9\.-]*\)/\1/'`
    echo "${PL_CODE} is located (${PL_LAT}, ${PL_LON})"
fi

# Calculate the lower and upper limits for both the longitude and latitude
PL_LAT_UPPER=`echo "scale=2; ${PL_LAT} + ${PL_TOL}" | bc`
PL_LAT_LOWER=`echo "scale=2; ${PL_LAT} - ${PL_TOL}" | bc`
PL_LON_UPPER=`echo "scale=2; ${PL_LON} + ${PL_TOL}" | bc`
PL_LON_LOWER=`echo "scale=2; ${PL_LON} - ${PL_TOL}" | bc`

# Specify the SQL request
GET_CLOSEST_AIRPORT_REQUEST="
select (airpop.paxc)/1000 AS 'popularity', 
		places.code, places.code, 
		names.classical_name, names.extended_name, places.country_code,
		places.latitude, places.longitude
from airport_popularity AS airpop, 
	  ref_place_details AS places, ref_place_names AS names
WHERE places.longitude >= ${PL_LON_LOWER}
	  AND places.longitude <= ${PL_LON_UPPER}
	  AND places.latitude >= ${PL_LAT_LOWER}
	  AND places.latitude <= ${PL_LAT_UPPER}
	  AND airpop.airport_code = places.code
	  AND names.code = places.code
ORDER BY airpop.tpax DESC"

# Get the closest airports
echo "Get the closest airports of the (${PL_LAT} +/-${PL_TOL}, ${PL_LON} +/-${PL_TOL}) location:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "${GET_CLOSEST_AIRPORT_REQUEST}"
