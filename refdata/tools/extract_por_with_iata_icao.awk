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
# Input format:
# -------------
# Sample lines for the allCountries_w_alt.txt file:
# 6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^43.66272^7.20787^S^AIRP^FR^^B8^06^062^06088^0^3^-9999^Europe/Paris^2012-06-30^NCE^LFMN^^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de^Flughafen Nizza^^en^Nice Côte d'Azur International Airport^^es^Niza Aeropuerto^ps^fr^Aéroport de Nice Côte d'Azur^^en^Nice Airport^s
#
# Feature code (field #8 here; see also
# http://www.geonames.org/export/codes.html):
# AIRB: Air base; AIRF: Air field; AIRH: Heliport; AIRP: Airport; 
# AIRQ: Abandoned air field; AIRS: Seaplane landing field
# RSTN: Railway station
# BUSTN: Bus station; BUSTP: Bus stop
# PPLx: Populated place
# ADMx: Administrative division
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
}


##
# The format of allCountries_w_alt.txt file is very similar to the Geonames
# pristine allCountry.txt data file.
#
/^([0-9]{1,9})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
	#
	por_lines++

	# Feature sub-code
	feat_subcode = $8

	# IATA code
	iata_code = $20

	# ICAO code
	icao_code = $21

	# FAA code
	faa_code = $22

	# English Wikipedia link
	wiki_link_code = $23

	# Calculate the flags corresponding to the type
	is_city = match ($8, "^ADM.*$") + match ($8, "^PPL.*$")
	is_travel = match ($8, "^AIRB$") + match ($8, "^AIRF$")
	is_travel += match ($8, "^AIRH$") + match ($8, "^AIRP$")
	is_travel += match ($8, "^AIRS$") + match ($8, "^RSTN$")
	is_travel += match ($8, "^BUSTN$") + match ($8, "^BUSTP$")

	# Dump the line into the output file
	if (is_travel >= 1) {
		print ($0) > iata_tvl_file
	}
	if (is_city >= 1) {
		print ($0) > iata_cty_file
	}
}


##
#
END {
	print ("Number of POR lines: " por_lines)
}
