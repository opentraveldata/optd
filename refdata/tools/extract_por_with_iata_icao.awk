##
# That AWK script extracts information from the 'allCountries_w_alt.txt'
# Geonames-derived data file:
# - For all the transport-related points of reference (POR,
#   i.e., mainly airports, airbases, airfields, heliports).
# - For all the populated places (i.e., cities) and administrative
#   divisions (e.g., municipalities) having got a IATA code (e.g., 'LON' for
#   London, UK, 'PAR' for Paris, France and 'SFO' for San Francisco, CA, USA).
#
# See ../geonames/data/por/admin/aggregateGeonamesPor.sh for more details on
# the way to derive that file from Geonames original data files.
#
# The format of allCountries_w_alt.txt file corresponds to what is expected. So,
# no further processing has to be done on the format here. However, data is extracted
# in two files, as seen above, just to keep the compatibility with the MySQL-based
# generation process. Moreover, all the POR having no IATA code is filtered out.
# Hence, the remaining of the Shell/AWK scripts, then, can be left untouched.
#
# Input format:
# -------------
# Sample lines for the allCountries_w_alt.txt file:
# NCE^LFMN^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^S^AIRP^B8^06^062^06088^0^3^-9999^Europe/Paris^^^^^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de^Flughafen Nizza^^en^Nice Côte d'Azur International Airport^^es^Niza Aeropuerto^ps^fr^Aéroport de Nice Côte d'Azur^^en^Nice Airport^s
#
# A few examples of Geonames feature codes
# (field #11 here; see also http://www.geonames.org/export/codes.html):
#  * PPLx:  Populated place (city)
#  * ADMx:  Administrative division (which may be a city in some cases)
#  * AIRB:  Air base; AIRF: Air field; AIRP: Airport; AIRS: Seaplane landing
#           field
#  * AIRQ:  Abandoned air field
#  * AIRH:  Heliport
#  * FY:    Ferry port
#  * PRT:   Maritime port
#  * RSTN:  Railway station
#  * BUSTN: Bus station; BUSTP: Bus stop
#
# Output format:
# Geoname ID, Name, ASCII name, Latitude, Longitude,
# Country, Country code 2, Feature class, Feature code,
# Administrative code 1, Administrative code 2,
# Administrative code 3, Administrative code 4,
# Population, Elevation, Topo 30,
# Time zone, GMT_offset, DST_offset, raw_offset,
# Modification date, List of all the alternate names without details,
# [(Language ISO code, alternate name)|("link", English Wikipedia link)]*


##
# Initialisation
BEGIN {
	#
	por_lines = 0

	#
	if (iata_tvl_file == "") {
		iata_tvl_file = "/dev/stdout"
	}
	if (iata_cty_file == "") {
		iata_cty_file = "/dev/stdout"
	}

	# Header
	hdr_line = "iata_code^icao_code^geonameid^name^asciiname^latitude^longitude"
	hdr_line = hdr_line "^country^cc2^fclass^fcode^admin1^admin2^admin3^admin4"
	hdr_line = hdr_line "^population^elevation^gtopo30"
	hdr_line = hdr_line "^timezone^GMT_offset^DST_offset^raw_offset^moddate^alternatenames"
	hdr_line = hdr_line "^wiki_link^altname_iso^altname_text^altname_flags"

	print (hdr_line) > iata_tvl_file
	print (hdr_line) > iata_cty_file
}


##
#
function is_tvl_or_cty (feat_code) {
	# Calculate the flags corresponding to the type
	is_city = match (feat_code, "^ADM.*$") + match (feat_code, "^PPL.*$")
	is_travel = match (feat_code, "^AIRB$") + match (feat_code, "^AIRF$")
	is_travel += match (feat_code, "^AIRH$") + match (feat_code, "^AIRP$")
	is_travel += match (feat_code, "^AIRS$") + match (feat_code, "^RSTN$")
	is_travel += match (feat_code, "^BUSTN$") + match (feat_code, "^BUSTP$")
	is_travel += match (feat_code, "^BUSTN$") + match (feat_code, "^BUSTP$")
	is_travel += match (feat_code, "^NVB") + match (feat_code, "^PRT")
	is_travel += match (feat_code, "^FY")
}


##
# POR entries having neither a IATA nor a ICAO code (vast majority of the POR).
# Sample:
# ^^3022309^Cros-de-Cagnes^Cros-de-Cagnes^43.66405^7.1722^FR^^P^PPL^B8^06^061^06027^0^2^19^Europe/Paris^^^^2012-02-27^Cros-de-Cagnes^^^Cros-de-Cagnes^
#
/^\^\^([0-9]{1,9})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
	# Feature code
	fcode = $11

	# Calculate whether it is travel- or city-related
	is_tvl_or_cty(fcode)

	if (is_travel >= 1 || is_city >= 1) {
		# Set the IATA and ICAO codes to "NULL". AWK recalculates the whole line ($0).
		OFS = FS
		$1 = "NULL"
		$2 = "NULL"

		# 
		print ($0) > iata_nocode_file
	}
}

##
# POR entries having only a ICAO code (and no IATA code)
# Sample:
# ^BGKS^7730417^Kangersuatsiaq Heliport^Kangersuatsiaq Heliport^72.39667^-55.555^GL^^S^AIRH^03^^^^0^^-9999^America/Godthab^^^^2012-02-26^BGKS,KAQ^http://en.wikipedia.org/wiki/Kangersuatsiaq_Heliport^
#
/^\^([A-Z0-9]{4})\^([0-9]{1,9})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
	# Feature code
	fcode = $11

	# Calculate whether it is travel- or city-related
	is_tvl_or_cty(fcode)

	if (is_travel >= 1 || is_city >= 1) {
		# Set the IATA code to "NULL". AWK recalculates the whole line ($0).
		OFS = FS
		$1 = "NULL"

		print ($0) > iata_icaoonly_file
	}
}

##
# The format of allCountries_w_alt.txt file corresponds to what is expected. So,
# no processing has to be done here. The data file is split in two, so as to keep
# compatibility with the MySQL-based generation process.
#
# NCE^LFMN^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^S^AIRP^B8^06^062^06088^0^3^-9999^Europe/Paris^^^^^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de^Flughafen Nizza^^en^Nice Côte d'Azur International Airport^^es^Niza Aeropuerto^ps^fr^Aéroport de Nice Côte d'Azur^^en^Nice Airport^s
/^([A-Z0-9]{3})\^([A-Z0-9]{4}|)\^([0-9]{1,9})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
	#
	por_lines++

	# Feature code
	fcode = $11

	# IATA code
	iata_code = $1

	# ICAO code
	icao_code = $2

	# FAA code
	#faa_code = $xx

	# Geoname ID
	geoname_id = $3

	# English Wikipedia link
	wiki_link_code = $25

	# Calculate whether it is travel- or city-related
	is_tvl_or_cty(fcode)

	# Dump the line into one of the output files
	if (is_travel >= 1) {
		# Travel-related

		if (icao_code != "") {
			# Travel-related with a ICAO code (e.g., airports)
			print ($0) > iata_tvl_file

		} else {
			# Travel-related with no ICAO code (e.g., some airports, train/bus stations).
			# Set the ICAO code to "NULL". AWK recalculates the whole line ($0).
			OFS = FS
			$2 = "NULL"

			print ($0) > iata_noicao_file
		}
	}

	if (is_city >= 1) {

		# Normally, the cities have no ICAO code
		if (icao_code == "") {
			# Set the ICAO code to "NULL". AWK recalculates the whole line ($0).
			OFS = FS
			$2 = "NULL"

		} else {
			print ("[" FNR "] The POR having got geoname_id=" geoname_id " is a city, but has got a ICAO code (" icao_code "), which is not normal") > "/dev/stderr"
		}
		
		# Cities
		print ($0) > iata_cty_file
	}
}


##
#
END {
	print ("Number of POR lines: " por_lines)
}
