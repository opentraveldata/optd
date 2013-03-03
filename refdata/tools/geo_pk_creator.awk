##
# That AWK script creates and adds a primary key for the Geonames dump file.
# It uses the following input files:
#  * Geonames dump data file:
#      dump_from_geonames.csv
#  * ORI-maintained list of best known coordinates:
#      best_coordinates_known_so_far.csv
#
# The primary key is made of:
#  * The IATA code
#  * The location type
#  * The Geonames ID, when existing, or 0 otherwise
# For instance:
#  * ARN-A-2725346 means the Arlanda airport in Stockholm, Sweden
#  * ARN-R-8335457 means the Arlanda railway station in Stockholm, Sweden
#  * CDG-A-6269554 means the Charles de Gaulle airport in Paris, France
#  * PAR-C-2988507 means the city of Paris, France
#  * NCE-CA-0 means Nice, France, indifferentiating the airport from the city
#  * SFO-A-5391989 means the San Francisco airport, California, USA
#  * SFO-C-5391959 means the city of San Francisco, California, USA
#
# A few examples of IATA location types:
#  * 'C' for city
#  * 'A' for airport
#  * 'CA' for a combination of both
#  * 'H' for heliport
#  * 'R' for railway station
#  * 'B' for bus station,
#  * 'P' for (maritime) port,
#  * 'G' for ground station,
#  * 'O' for off-line point (usually a small city/village or a railway station)
#
# A few examples of Geonames feature codes
# (see http://www.geonames.org/export/codes.html):
#  * PPLx:  Populated place (city)
#  * ADMx:  Administrative division (which may be a city in some cases)
#  * LCTY:  Locality (e.g., Sdom)
#  * PCLI:  Political entity (country, e.g., Bahrain, Monaco)
#  * ISLx:  Island (e.g., Dalma Island)
#  * AIRB:  Air base; AIRF: Air field; AIRP: Airport; AIRS: Seaplane landing
#           field
#  * AIRQ:  Abandoned air field
#  * AIRH:  Heliport
#  * FY:    Ferry port
#  * PRT:   Maritime port
#  * RSTN:  Railway station
#  * BUSTN: Bus station; BUSTP: Bus stop
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
function overrideDetails(myPK, myFullLine, myFeatClass, myFeatCode) {
	# Sample input line:
	# AAN^OMAL^^6300095^Al Ain International Airport^Al Ain International Airport^24.26167^55.60917^AE^^United Arab Emirates^Asia^S^AIRP^^^^^^^^^0^264^248^Asia/Dubai^4.0^4.0^4.0^2007-01-03^AAN,OMAL^http://en.wikipedia.org/wiki/Al_Ain_International_Airport^

	# Save the line
	saved_line = $0

	# Reparse the line
	OFS = FS
	$0 = myFullLine

	# Override the ICAO code
	$2 = "ZZZZ"
				
	# Override the FAA code
	$3 = ""
				
	# Override the Geonames ID
	$4 = "0"

	# Override the feature class and code
	$13 = myFeatClass; $14 = myFeatCode
				
	# Override the alternate names and Wikipedia link
	$31 = ""; $32 = ""

	# Cut the line after the Wikipedia link (remove any alternate name)
	NF = 32

	# Add an empty last field (for the section of alternate names)
	print (myPK "^" $0 "^")

	# Restore the initial line
	$0 = saved_line
}

##
# The POR/lines have to be combined or split the same way as in the ORI list:
#  - A single, combined, POR for a 'CX' location type (X = A, H, B, R, P, O, G)
#  - One POR by other location type (e.g., 'C', 'A', 'H', 'R', 'B', 'P', 'O',
#    'G')
#
function displayPOR(myIataCode, myLastPK, myPK, myLastAltPK,			\
					myTravelLine, myCityLine, myNbOfPOR, myLastLine, myLine) {

	# DEBUG
	# print ("[" myIataCode "] myLastPK=" myLastPK ", myPK=" myPK			\
	#	   ", myLastAltPK=" myLastAltPK ", myNbOfPOR=" myNbOfPOR) > error_stream

	# Retrieve the full location type from the ORI-maintained list
	myLocationType = ori_loc_type_list[myIataCode]
	myLocationTypeAlt = ori_loc_type_alt_list[myIataCode]
	# Retrieve the Geoanames ID from the ORI-maintained list
	myGeonamesID = ori_geoid_list[myIataCode]
	myGeonamesIDAlt = ori_geoid_alt_list[myIataCode]

	if (myNbOfPOR >= 2) {
		# There are two POR in Geonames sharing the same IATA code

		if (myIataCode in combined_list) {
			# The location type is made of several characters (by construction
			# of the 'combined_list' list).

			# Notification
			if (log_level >= 5) {
				print ("[" awk_file "] !! Notification: the POR #" FNR \
					   " and #" FNR-1 ", with IATA code=" myIataCode \
					   ", are distinct in Geonames, but combined in the " \
					   "ORI-maintained list. You could split it in ORI." \
					   " Both POR:\n" myLastLine "\n" myLine) > error_stream
			}

			# The travel-related POR will inherit from the location type
			# associated (by ORI) to that POR. The city POR will be left
			# untouched.
			print (myLastPK "^" myTravelLine)
			#print (myIataCode "-C-" myGeonamesID "^" myCityLine)

		} else if (myLocationTypeAlt == "") {
			# The location type is made of a single character (otherwise, that
			# POR would be part of the 'combined_list' list, by construction of
			# that latter).
			#
			# Moreover, there is no alternate location type for that IATA code,
			# meaning that there is a single line in the ORI-maintained list.

			# City-related type
			is_city = isLocTypeCity(myLocationType)

			# Travel-related type
			is_travel = isLocTypeTvlRtd(myLocationType)

			if (is_travel >= 1) {
				# Notification
				if (log_level >= 5) {
					print ("[" awk_file "] !! Notification: the POR #" FNR \
						   " and #" FNR-1 ", with IATA code=" myIataCode \
						   ", are distinct in Geonames, but combined as a " \
						   "travel-related point in the ORI-maintained list. " \
						   "You could split it in ORI. Both POR:\n" myLastLine \
						   "\n" myLine) > error_stream
				}

				# The travel-related POR will inherit from the location type
				# associated (by ORI) to that POR. The city POR will be left
				# untouched.
				print (myLastPK "^" myTravelLine)
				#print (myIataCode "-C-" myGeonamesID "^" myCityLine)

			} else if (is_city >= 1) {
				# Notification
				if (log_level >= 5) {
					print ("[" awk_file "] !! Notification: the POR #" FNR \
						   " and #" FNR-1 ", with IATA code=" myIataCode \
						   ", are distinct in Geonames, but combined as a city" \
						   " in the ORI-maintained list. "				\
						   "You could split it in ORI. Both POR:\n" myLastLine \
						   "\n" myLine) > error_stream
				}

				# The city POR will inherit from the location type associated
				# (by ORI) to that POR. The travel-related POR will be left
				# untouched.
				#print (myLastPK "^" myTravelLine)
				print (myIataCode "-C-" myGeonamesID "^" myCityLine)

			} else {
				# Notification
				print ("[" awk_file "] !! Error: the POR #" FNR " and #" FNR-1 \
					   ", with IATA code=" myIataCode					\
					   ", are distinct in Geonames, but combined "		\
					   " in the ORI-maintained list. However, the location"	\
					   "type ('" myLocationType "') is unknown. Both POR:\n" \
					   myLastLine "\n" myLine) > error_stream
			}

		} else {
			# The ORI-maintained list does provide two distinct lines for that
			# IATA code, exactly like for Geonames. So, both lines are
			# copied here. By construction of the primary key and alternative
			# primary key, the travel-related one is the former (primary key)
			# and the city-related one the latter (alternative primary key).
			# When the alternative key is not city-related, it still comes
			# in second position.
			print (myLastPK "^" myTravelLine)
			print (myLastAltPK "^" myCityLine)
		}

	} else {
		# There is a single POR in Geonames for that IATA code.

		if ((length(myLocationType) == 1 && myLocationTypeAlt == "") \
			|| myIataCode in combined_list) {
			# There is also a single POR in the ORI-maintained list. It may be
			# either:
			#  - A combined case ('CA'), such as NCE
			#  - A mono-typed case (e.g., 'C', 'A', 'H'), such as LON or LHR
			print (myLastPK "^" myLastLine)

		} else {
			# There are two POR in the ORI-maintained list sharing
			# that IATA code. The details have therefore to be "invented",
			# according to the second location type.
			print (myLastPK "^" myLastLine)

			# DEBUG
			# print ("[" myIataCode "][" myLastPK "][" myLastAltPK "]{" \
			#        myLocationType "}{" myLocationTypeAlt "} " myLastLine) \
			#    > error_stream

			myFeatClass = getFeatureClass(myLocationTypeAlt)
			myFeatCode = getFeatureCode(myLocationTypeAlt)
			overrideDetails(myLastAltPK, myLastLine, myFeatClass, myFeatCode)

			if (myFeatClass == "NA" || myFeatCode == "NA") {
				# Notification
				if (log_level >= 4) {
					print ("[" awk_file "] !! Notification: For the line #" FNR \
						   " and the '" myIataCode \
						   "' IATA code, the details of the second POR have " \
						   "to be invented. However, the second " \
						   "location type ('" myLocationTypeAlt			\
						   "') is unknown (first location type: '"		\
						   myLocationType "') - Full line: " myLastLine) \
						> error_stream
				}
			}

			# Notification
			if (log_level >= 4) {
				print ("[" awk_file "] !! Notification: For the line #" FNR \
					   " and the '" myIataCode \
					   "' IATA code, the details of the second "		\
					   "POR had to be duplicated because the ORI-maintained " \
					   "list has got two entries (the location types being '" \
					   myLocationTypeAlt "' and '" myLocationType \
					   "') - Full original and invented lines: " myLastLine \
					   "\n" $0) > error_stream
			}

			# Sanity check: by construction, the location type is
			# multi-character; an alternative location type should
			# therefore be specified.
			if (myLocationTypeAlt == "") {
				print ("[" awk_file "] !!!! Error at line #" FNR \
					   " for the '" myIataCode							\
					   "' IATA code; the location type ('" myLocationType \
					   "') has got at least two characters, while no " \
					   "alternative location has been defined (check also " \
					   "the ORI-maintained list) - Full line: " myLastLine) \
					> error_stream
			}
		}
	}
}


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "geo_pk_creator.awk"

	# Number of last registered Geonames POR entries
	nb_of_geo_por = 0

	#
	resetORILineList()
}

##
#
BEGINFILE {
	# Global variables
	resetGeonamesLineList()
}

##
# The ../ORI/best_coordinates_known_so_far.csv data file is used, in order to
# specify the POR primary key and its location type.
#
# Sample lines:
#  ALV-C-3041563^ALV^42.50779^1.52109^ALV^ (2 lines in ORI, 2 lines in Geonames)
#  ALV-O-7730819^ALV^40.98^0.45^ALV^       (2 lines in ORI, 2 lines in Geonames)
#  ARN-A-2725346^ARN^59.651944^17.918611^STO^ (2 lines in ORI, split from a
#  ARN-R-8335457^ARN^59.649463^17.929^STO^     combined line, 1 line in Geonames)
#  IES-CA-2846939^IES^51.3^13.28^IES^(1 combined line in ORI, 1 line in Geonames)
#  IEV-A-6300960^IEV^50.401694^30.449697^IEV^(2 lines in ORI, split from a
#  IEV-C-703448^IEV^50.401694^30.449697^IEV^  combined line, 2 lines in Geonames)
#  KBP-A-6300952^KBP^50.345^30.894722^IEV^   (1 line in ORI, 1 line in Geonames)
#  LHR-A-2647216^LHR^51.4775^-0.461389^LON^  (1 line in ORI, 1 line in Geonames)
#  LON-C-2643743^LON^51.5^-0.1667^LON^       (1 line in ORI, 1 line in Geonames)
#  NCE-CA-0^NCE^43.658411^7.215872^NCE^      (1 combined line in ORI
#                                             2 lines in Geonames)
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})\^([A-Z]{3})\^/ {
	# Store the full line
	full_line = $0

	# Primary key (combination of IATA code, location type and Geonames ID)
	pk = $1

	# IATA code of the POR (it should be the same as the one of the primary key)
	iata_code2 = $2

	# Geographical coordinates
	latitude = $3
	longitude = $4

	# IATA code of the served city
	srvd_city_code = $5

	# Beginning date of the validity range
	beg_date = $6

	# Register the ORI-maintained line
	registerORILine(pk, iata_code2, latitude, longitude, \
					srvd_city_code, beg_date,			 \
					full_line, awk_file, error_stream)
}


####
## Geonames dump file

##
# Geonames header line
/^iata_code/ {
	print ("pk^" $0)
}

##
# Geonames regular lines
# Sample lines (truncated):
#  IEV^UKKK^^6300960^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.40169^30.4497^UA^^Ukraine^Europe^S^AIRP^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Kyiv Airport,...^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|
#  IEV^ZZZZ^^703448^Kiev^Kiev^50.45466^30.5238^UA^^Ukraine^Europe^P^PPLC^12^Kyiv City^Kyiv City^^^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-08-18^Kiev,...,Київ^http://en.wikipedia.org/wiki/Kiev^en|Kiev|h|en|Kyiv|p
#  LHR^EGLL^^2647216^London Heathrow Airport^London Heathrow Airport^51.47115^-0.45649^GB^^United Kingdom^Europe^S^AIRP^ENG^England^England^GLA^Greater London^Greater London^F9^^0^^27^Europe/London^0.0^1.0^0.0^2010-08-03^London Heathrow,...,伦敦 海斯楼 飞机场,倫敦希斯路機場,런던 히드로 공항^http://en.wikipedia.org/wiki/London_Heathrow_Airport^en|Heathrow Airport||en|Heathrow|s
#  LON^ZZZZ^^2643743^London^London^51.50853^-0.12574^GB^^United Kingdom^Europe^P^PPLC^ENG^England^England^GLA^Greater London^Greater London^^^7556900^^25^Europe/London^0.0^1.0^0.0^2012-08-19^City of London,...伦敦,倫敦^http://en.wikipedia.org/wiki/London^en|London|p|en|London City|
#  NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Nice Airport,...^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Airport|s
#  NCE^ZZZZ^^2990440^Nice^Nice^43.70313^7.26608^FR^^France^Europe^P^PPLA2^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2011-11-02^Nice,...,Ница,尼斯^http://en.wikipedia.org/wiki/Nice^en|Nice||ru|Ницца|
#
/^([A-Z]{3})\^([A-Z0-9]{0,4})\^([A-Z0-9]{0,4})\^([0-9]{1,10})\^/ {
	#
	nb_of_geo_por++

	# IATA code
	iata_code = $1

	# Geonames ID
	geonames_id = $4

	# Feature code
	fcode = $14

	# Store the full line
	full_line = $0

	# Register the full line
	registerGeonamesLine(iata_code, fcode, geonames_id,	full_line,		\
						 awk_file, error_stream, log_level,	nb_of_geo_por)

	# Debugging mode
	# if (FNR >= 11) { exit }
}

#
ENDFILE {
	# DEBUG
	if (nb_of_geo_por == 0) {
		# displayLists()
	}
}

#
END {
	# Display the last Geonames POR entries
	displayGeonamesPOREntries(awk_file, error_stream, log_level)
}

