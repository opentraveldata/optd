##
# That AWK script capitalises the names within the Amadeus RFD dump file.
#
# The format of the Amadeus RFD dump file is assumed to be the following:
# - [1]  iata_code^
# - [2]  location_type^
# - [3]  ticketing_name^
# - [4]  detailed_name^
# - [5]  teleticketing_name^
# - [6]  extended_name^
# - [7]  city_name^
# - [8]  rel_city_code^
# - [9]  is_airport^
# - [10] state_code^
# - [11] rel_country_code^
# - [12] rel_region_code^
# - [13] rel_continent_code^
# - [14] rel_time_zone_grp^
# - [15] latitude^
# - [16] longitude^
# - [17] numeric_code^
# - [18] is_commercial
#

##
# Helper functions
@include "awklib/geo_lib.awk"

##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "rfd_capitalise.awk"
	idx_por = 0
}


####
## Amadeus RFD dump file

##
# Amadeus RFD header line
/^iata_code/ {
	print ($0)
}

##
# Amadeus RFD regular lines
# Sample lines (truncated):
#  BFJ^^BA^BUCKLEY ANGB^BA^BA/FJ:BA^BA^BFJ^Y^^FJ^AUSTL^ITC3^FJ169^^^^N
#  IEV^CA^KIEV ZHULIANY INT^ZHULIANY INTL^KIEV ZHULIANY I^KIEV/UA:ZHULIANY INTL
#    ^KIEV^IEV^Y^^UA^EURAS^ITC2^UA127^50.4^30.4667^2082^Y
#  KBP^A^KIEV BORYSPIL^BORYSPIL INTL^KIEV BORYSPIL^KIEV/UA:BORYSPIL INTL
#    ^KIEV^IEV^Y^^UA^EURAS^ITC2^UA127^50.35^30.9167^2384^Y
#  LHR^A^LONDON LHR^HEATHROW^LONDON LHR^LONDON/GB:HEATHROW
#    ^LONDON^LON^Y^^GB^EUROP^ITC2^GB053^51.4761^-0.63222^2794^Y
#  LON^C^LONDON^^LONDON^LONDON/GB
#    ^LONDON^LON^N^^GB^EUROP^ITC2^GB053^51.5^-0.16667^^N
#  NCE^CA^NICE^COTE D AZUR^NICE^NICE/FR:COTE D AZUR
#    ^NICE^NCE^Y^^FR^EUROP^ITC2^FR052^43.6653^7.215^^Y
#
/^([A-Z]{3})\^([A-Z]*)\^/ {
	# DEBUG
	#idx_por++
	#if (idx_por >= 2) {
	#	exit
	#}

	# IATA code
	iata_code = $1

	# Sanity check: if the fields change, it is wiser to be warned.
	if (NF != 18) {
		print ("[" awk_file "] !!!! Error at line #" FNR " for the '" iata_code \
			   "' IATA code; the number of fields is not equal to 18 "	\
			   "- Full line: " $0) > error_stream
	}

	# Override the output separator (to be equal to the input one)
	OFS = FS

	# Ticketing name
	ticketing_name = capitaliseWords($3)
	$3 = ticketing_name

	# Detailed name
	detailed_name = capitaliseWords($4)
	$4 = detailed_name

	# Teleticketing name
	teleticketing_name = capitaliseWords($5)
	$5 = teleticketing_name

	# Extended name
	extended_name = capitaliseWords($6)
	$6 = extended_name

	# City name
	city_name = capitaliseWords($7)
	$7 = city_name
	
	# Print the amended line
	print ($0)

}

#
ENDFILE {
	# DEBUG
}

