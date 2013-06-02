##
# That AWK script:
#  1. Adds the name, in both UTF8 and ASCII encodings, of the served cities.
#  2. Adds the list of travel-related POR IATA codes.
# The ori_por_public.csv data file is parsed twice:
#  * once to store, in memory, the city names,
#  * the second time to write the corresponding fields in that very same
#    ori_por_public.csv file, which is therefore amended.
#
# As of June 2013 (see also the "Fields" part in the BEGIN{} section):
#  * The POR IATA code is the field #1
#  * The POR UTF8 name is the field #7
#  * The POR ASCII name is the field #8
#  * The (list of) city code(s) is the field #37
#  * The (list of) city UTF8 name(s) is the field #38
#  * The (list of) city ASCII name(s) is the field #39
#  * The list of travel-related POR IATA codes is the field #40
#  * The location type is the field #42
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "add_city_name.awk"

	# Fields
	K_POR_CDE = 1
	K_NME_UTF = 7
	K_NME_ASC = 8
	K_SVD_CTY_LST = 37
	K_CTY_UTF_LST = 38
	K_CTY_ASC_LST = 39
	K_TVL_LST = 40
	K_LOC_TYP = 42

	#
	idx_file = 0
}


##
#
BEGINFILE {
	#
	idx_file++

	# Sanity check
	if (idx_file >=3) {
		print ("[" awk_file "] !!!! Error - The '" FILENAME "' data file " \
			   "should not be parsed more than twice" ) > error_stream
	}
}

##
# First parsing - extraction of the city (UTF8 and ASCII) names
function extractAndStoreCityNames(porIataCode, porUtfName, porAsciiName, \
								  porLocType) {
	# Parse the location type
	is_city = isLocTypeCity(porLocType)
	is_tvl = isLocTypeTvlRtd(porLocType)

	# Store the names of the point of reference (POR) when it is a city
	if (is_city != 0) {
		name_utf_list[porIataCode] = porUtfName
		name_ascii_list[porIataCode] = porAsciiName
	}
}

##
# First parsing - collection of the travel-related points serving a given city
function collectTravelPoints(porIataCodePk, porIataCodeServedList, porLocType) {
	# Store the names of the point of reference (POR) when it is not only a city
	if (porLocType != "C") {

		# Split the list of cities
		# Note: most of the time, that list contains a single IATA code
		split (porIataCodeServedList, porIataCodeServedArray, ",")
		for (porIataCodeServedIdx in porIataCodeServedArray) {
			porIataCodeServed = porIataCodeServedArray[porIataCodeServedIdx]

			tvl_por_list = travel_por_list_array[porIataCodeServed]
			if (tvl_por_list == "") {
				travel_por_list_array[porIataCodeServed] = porIataCodePk
			} else {
				travel_por_list_array[porIataCodeServed] =	\
					tvl_por_list "," porIataCodePk
			}
		}
	}
}

##
# Second parsing - writing of the city (UTF8 and ASCII) names
function writeCityNames(porIataCode, porLocType, porIataCodeServedList, \
						porUtfName, porAsciiName) {
	# Output separator
	OFS = FS

	# Split the list of city code(s) and (arbitrarily) take the first one.
	# Note: most of the time, that list contains a single IATA code.
	split (porIataCodeServedList, porIataCodeServedArray, ",")
	porIataCodeServed = porIataCodeServedArray[1]

	# UTF8 name of the served city
	utfName = name_utf_list[porIataCodeServed]
	if (utfName == "") {
		utfName = porUtfName
	}
	$K_CTY_UTF_LST = utfName

	# ASCII name of the served city
	asciiName = name_ascii_list[porIataCodeServed]
	if (asciiName == "") {
		asciiName = porAsciiName
	}
	$K_CTY_ASC_LST = asciiName
}

##
# Second parsing - writing of the travel-related points serving a given city
function writeTravelPORList(porIataCode, porLocType, porIataCodeServedList) {
	# Parse the location type
	is_city = isLocTypeCity(porLocType)

	if (is_city != 0) {
		# Output separator
		OFS = FS

		# Split the list of city code(s) and (arbitrarily) take the first one.
		# Note: most of the time, that list contains a single IATA code.
		split (porIataCodeServedList, porIataCodeServedArray, ",")
		porIataCodeServed = porIataCodeServedArray[1]

		# Travel-related POR list
		tvl_por_list = travel_por_list_array[porIataCodeServed]
		$K_TVL_LST = tvl_por_list
	}
}

##
# Header
/^iata_code\^/ {
	if (idx_file == 2) {
		print ($0)
	}
}

##
# Sample input and output lines:
# iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id^name^asciiname^latitude^longitude^fclass^fcode^page_rank^date_from^date_until^comment^country_code^cc2^country_name^continent_name^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3_code^adm4_code^population^elevation^gtopo30^timezone^gmt_offset^dst_offset^raw_offset^moddate^city_code^city_name_utf^city_name_ascii^tvl_por_list^state_code^location_type^wiki_link^alt_name_section
#
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|
#
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
#
/^([A-Z0-9]{3})\^([A-Z0-9]{0,4})\^([A-Z0-9]{0,4})\^/{

	if (idx_file == 1) {
		##
		# First parsing

		# IATA code of the point of reference (POR) itself
		iata_code = $K_POR_CDE

		# UTF8 name of the POR itself
		name_utf = $K_NME_UTF

		# ASCII name of the POR itself
		name_ascii = $K_NME_ASC

		# Served city IATA code
		served_city_code_list = $K_SVD_CTY_LST

		# IATA location type
		location_type = $K_LOC_TYP

		# Store the POR names for the POR IATA code
		extractAndStoreCityNames(iata_code, name_utf, name_ascii, location_type)

		# Collect the travel-related POR IATA code
		collectTravelPoints(iata_code, served_city_code_list, location_type)

	} else if (idx_file == 2) {
		##
		# Second parsing

		# IATA code of the point of reference (POR) itself
		iata_code = $K_POR_CDE

		# UTF8 name of the POR itself
		name_utf = $K_NME_UTF

		# ASCII name of the POR itself
		name_ascii = $K_NME_ASC

		# IATA code of the city served by that POR
		city_iata_code_list = $K_SVD_CTY_LST

		# IATA location type
		location_type = $K_LOC_TYP

		# Write the city names for that POR
		writeCityNames(iata_code, location_type, city_iata_code_list, \
					   name_utf, name_ascii)

		# Write the travel-related points serving a given city
		writeTravelPORList(iata_code, location_type, city_iata_code_list)

		# Write the full line, amended by the call to the writeCityNames()
		# function
		print ($0)

	} else {
		# Sanity check
		print ("[" awk_file "] !!!! Error - The '" FILENAME "' data file " \
			   "should not be parsed more than twice" ) > error_stream
	}
}
