##
# That AWK script creates and adds a primary key for the Amadeus RFD dump file.
# The primary key is made of the IATA code and location type. For instance:
#  * ARN-A means the Arlanda airport in Stockholm, Sweden
#  * ARN-R means the Arlanda railway station in Stockholm, Sweden
#  * CDG-A means the Charles de Gaulle airport in Paris, France
#  * PAR-C means the city of Paris, France
#  * NCE-CA means Nice, France, indifferentiating the airport from the city
#  * SFO-A means the San Francisco airport, California, US
#  * SFO-C means the city of San Francisco, California, US
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
# That script relies on the ORI-maintained list of POR (points of reference),
# provided by the OpenTravelData project (http://github.com/opentraveldata/optd).
# Issue the 'prepare_rfd_dump_file.sh --geonames' command to see more detailed
# instructions.
#

# Helper functions
function displayList(myListType, myList) {
	print (myListType ":")
	for (idx in myList) {
		print (idx)
	}
}
function displayLists() {
	displayList("Cities", city_list)
	displayList("Airports", airport_list)
	displayList("Ports", port_list)
	displayList("Heliports", heliport_list)
	displayList("Railway stations", rail_list)
	displayList("Bus stations", bus_list)
	displayList("Ground stations", ground_list)
	displayList("Off-line points", offpoint_list)
}

#
function registerPOR(myIataCode, myLocationType, myFullLine) {
	# Check whether the POR is a city. It can be a city only or, most often,
	# a combination of a city with a travel-related type (e.g., airport,
	# rail station). In some rare cases, an airport may be combined with
	# something else than a city (e.g., railway station); ARN is such an
	# example, and CDG might be another one.
	is_city = match (myLocationType, "C")

	# Travel-related type
	is_airport = match (myLocationType, "A")
	is_rail = match (myLocationType, "R")
	is_bus = match (myLocationType, "B")
	is_heliport = match (myLocationType, "H")
	is_port = match (myLocationType, "P")
	is_ground = match (myLocationType, "G")
	is_offpoint = match (myLocationType, "O")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port \
		+ is_ground + is_offpoint

	# Sanity check
	if (length(myLocationType) >= 2 && is_travel == 0) {
		print ("[" awk_file "] !!!! Error at line #" FNR ", the location type ('" \
			   myLocationType "') is unknown - Full line: " myFullLine) \
			> error_stream
	}

	# Store the location types. If there are two location types for that POR,
	# the first should be the travel-related one and the second should be the
	# city.
	# Note that in some rare cases (e.g., ARN-AR, i.e. Stockholm Arlanda airport
	# and railway station, both serving STO-C), the location type is combined
	# ('AR' here), but there is no city.
	last_location_type = location_type_list[myIataCode]
	if (last_location_type == "") {
		# No location type has been registered yet
		location_type_list[myIataCode] = myLocationType

	} else {
		# A location type has already been registered
		is_last_city = match (last_location_type, "C")
		is_last_airport = match (last_location_type, "A")
		is_last_rail = match (last_location_type, "R")
		is_last_bus = match (last_location_type, "B")
		is_last_heliport = match (last_location_type, "H")
		is_last_port = match (last_location_type, "P")
		is_last_ground = match (last_location_type, "G")
		is_last_offpoint = match (last_location_type, "O")
		is_last_travel = is_last_airport + is_last_rail + is_last_bus \
			+ is_last_heliport + is_last_port + is_last_ground + is_last_offpoint

		if (is_last_city != 0) {
			# The previously registered location type is a city. So, it is now
			# re-registered in second position. The first position is devoted to
			# the travel-related POR.
			location_type_list[myIataCode] = myLocationType
			location_type_alt_list[myIataCode] = last_location_type

			# Sanity check: the new location type should be travel-related
			if (is_travel == 0) {
				print ("[" awk_file "] !!!! Rare case at line #" FNR \
					   ", there are at least two location types ('" \
					   last_location_type "' and '" myLocationType \
					   "'), but the latter one is neither a city nor " \
					   "travel-related - Full line: " myFullLine) \
					> error_stream
			}

		} else if (is_city != 0) {
			# The city is the new location type; the previously registered
			# one must then be travel-related.
			location_type_list[myIataCode] = last_location_type
			location_type_alt_list[myIataCode] = myLocationType

			# Sanity check: the last location type should be travel-related
			if (is_last_travel == 0) {
				print ("[" awk_file "] !!!! Rare case at line #" FNR \
					   ", there are at least two location types ('" \
					   last_location_type "' and '" myLocationType \
					   "'), but the former one is neither a city nor " \
					   "travel-related - Full line: " myFullLine) > error_stream
			}

		} else {
			# Neither the previously registered location type nor the current
			# one is a city. So, if there is an airport, it will be registered
			# in the first position; otherwise, the alphabetical order of the
			# location type is used by construction.
			if (is_last_airport != 0) {
				location_type_list[myIataCode] = last_location_type
				location_type_alt_list[myIataCode] = myLocationType

			} else if (is_airport != 0) {
				location_type_list[myIataCode] = myLocationType
				location_type_alt_list[myIataCode] = last_location_type

			} else {
				location_type_alt_list[myIataCode] = myLocationType
			}
		}
	}

	#
	if (is_city != 0) {
		city_list[myIataCode] = 1

		if (is_travel != 0) {
			combined_list[myIataCode] = 1
		}
	}

	if (is_travel != 0) {
		travel_list[myIataCode] = 1
	}

	if (is_airport != 0) {
		airport_list[myIataCode] = 1
	}

	if (is_rail != 0) {
		rail_list[myIataCode] = 1
	}

	if (is_bus != 0) {
		bus_list[myIataCode] = 1
	}

	if (is_heliport != 0) {
		heliport_list[myIataCode] = 1
	}

	if (is_port != 0) {
		port_list[myIataCode] = 1
	}

	if (is_ground != 0) {
		ground_list[myIataCode] = 1
	}

	if (is_offpoint != 0) {
		offpoint_list[myIataCode] = 1
	}
}


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "rfd_pk_creator.awk"
}


##
# The ../ORI/best_coordinates_known_so_far.csv data file is used, in order
# to specify the POR primary key )and its location type).
# Sample lines:
#  ALV-O^ALV^40.98^0.45^ALV^         (1 line in ORI, 2 lines in Geonames)
#  ARN-A^ARN^59.651944^17.918611^STO^(2 lines in ORI, split from a combined line,
#  ARN-R^ARN^59.649463^17.929^STO^    1 line in Geonames)
#  IES-CA^IES^51.3^13.28^IES^        (1 combined line in ORI, 1 line in Geonames)
#  IEV-A^IEV^50.401694^30.449697^IEV^(2 lines in ORI, split from a combined line,
#  IEV-C^IEV^50.401694^30.449697^IEV^ 2 lines in Geonames)
#  KBP-A^KBP^50.345^30.894722^IEV^   (1 line in ORI, 1 line in Geonames)
#  LHR-A^LHR^51.4775^-0.461389^LON^  (1 line in ORI, 1 line in Geonames)
#  LON-C^LON^51.5^-0.1667^LON^       (1 line in ORI, 1 line in Geonames)
#  NCE-CA^NCE^43.658411^7.215872^NCE^(1 combined line in ORI 2 lines in Geonames)
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^/ {

	# Primary key (combination of IATA code and location type)
	pk = $1

	# IATA code
	iata_code = $2

	# Location type
	location_type = substr (pk, 5)

	# Full line
	full_line = $0

	# Register the POR
	registerPOR(iata_code, location_type, full_line)
}


####
## Amadeus RFD dump file

##
# Amadeus RFD header line
/^iata_code/ {
	print ("pk^" $0)
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
	#
	nb_of_por++

	# IATA code
	iata_code = $1

	# Feature code
	rfd_loc_type = $2

	# If the location type is not specified, "CA" (airport and city) is taken
	if (rfd_loc_type == "") {
		rfd_loc_type = "CA"
	}

	#
	is_city = match (rfd_loc_type, "C")
	is_airport = match (rfd_loc_type, "A")
	is_rail = match (rfd_loc_type, "R")
	is_bus = match (rfd_loc_type, "B")
	is_heliport = match (rfd_loc_type, "H")
	is_port = match (rfd_loc_type, "P")
	is_ground = match (rfd_loc_type, "G")
	is_offpoint = match (rfd_loc_type, "O")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port \
		+ is_ground + is_offpoint


	# Retrieve the full location type from the ORI-maintained list
	location_type = location_type_list[iata_code]
	location_type_alt = location_type_alt_list[iata_code]

	# Sanity check: the POR should be known from ORI
	if (location_type == "") {
		print ("[" awk_file "] !!!! Error at line #" FNR \
			   ", the POR with that IATA code ('" iata_code \
			   "') is not referenced in the ORI-maintained list: " $0) > error_stream
	}

	# New primary key, made of the IATA code and ORI-maintained location type
	pk = iata_code "-" location_type
	pk_alt = iata_code "-" location_type_alt

	# The POR/lines have to be combined or split the same way as in the ORI list:
	#  - A single, combined, POR for a 'CX' location type (X = A, H, B, R, P, O)
	#  - One POR by other location type (e.g., 'C', 'A', 'H')
	#

	# As the IATA code is the primary key of the Amadeus RFD database,
	# there is a single POR in Amadeus RFD for that IATA code.

	OFS = FS
	if (location_type_alt == "" || iata_code in combined_list) {
		# There is also a single POR in the ORI-maintained list. It may be
		# either:
		#  - A combined case ('CA'), such as NCE
		#  - A mono-typed case (e.g., 'C', 'A', 'H'), such as LON or LHR
		#
		# Override the location type (field #2)
		$2 = location_type
		print (pk "^" $0)

	} else {
		# There are two POR in the ORI-maintained list sharing that IATA
		# code (e.g., SFO-A and SFO-C, ARN-A and ARN-R).
		# The Amadeus RFD details will therefore be duplicated.
		#
		# Override the location type (field #2)
		$2 = location_type
		print (pk "^" $0)

		# Override the location type (field #2), and state that it is not
		# an airport.
		$2 = location_type_alt
		$9 = "N"

		# State the POR is not commercial when it is a city
		if (location_type_alt == "C") {
			$18 = "N"
		}

		#
		print (pk_alt "^" $0)

		# Sanity check: by construction, the location type is multi-character;
		#               an alternative location type should therefore be
		#               specified.
		if (location_type_alt == "") {
			print ("[" awk_file "] !!!! Error at line #" FNR " for the '" iata_code \
				   "' IATA code; the location type ('" location_type \
				   "') has got at least two characters, while no alternative" \
				   " location has been defined (check also the ORI-maintained" \
				   " list) - Full line: " $0) > error_stream
		}
	}
}

#
ENDFILE {
	# DEBUG
	#displayLists()
}

