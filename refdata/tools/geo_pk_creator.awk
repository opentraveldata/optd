##
# That AWK script creates and adds a primary key for the Geonames dump file.
# The primary key is made of the IATA code and location type. For instance:
#  * CDG-A means the Charles de Gaulle airport in Paris, France
#  * PAR-C means the city of Paris, France
#  * NCE-CA means Nice, France, indifferentiating the airport from the city
#  * SFO-A means the San Francisco airport, California, US
#  * SFO-C means the city of San Francisco, California, US
#
# A few examples of ORI-maintained location types:
#  * 'C' for city
#  * 'A' for airport
#  * 'CA' for a combination of both
#  * 'R' for railway station
#  * 'B' for bus station,
#  * 'O' for off-line point
#
# A few examples of Geonames feature codes (http://www.geonames.org/export/codes.html):
#  * PPLx: Populated place (city)
#  * ADMx: Administrative division (which may be a city in some cases)
#  * AIRB: Air base; AIRF: Air field; AIRP: Airport; AIRS: Seaplane landing field
#  * AIRQ: Abandoned air field
#  * AIRH: Heliport
#  * RSTN: Railway station
#  * BUSTN: Bus station; BUSTP: Bus stop
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
	displayList("Off-line points", offpoint_list)
}

function displayPOR(myIataCode, myLastPK, myPK, myLastAltPK, myCityLine, myTravelLine, myNbOfPOR, myLastLine, myLine) {
	# The POR/lines have to be combined or split the same way as in the ORI list:
	#  - A single, combined, POR for a 'CX' location type (X = A, H, B, R, P, O)
	#  - One POR by other location type (e.g., 'C', 'A', 'H')
	#

	# Retrieve the full location type from the ORI-maintained list
	location_type = location_type_list[myIataCode]
	location_type_alt = location_type_alt_list[myIataCode]

	if (myNbOfPOR >= 2) {
		# There are two POR in Geonames sharing the same IATA code

		if (myIataCode in combined_list) {
			# Notification
			if (log_level >= 5) {
				print ("!! Notification: the POR #" FNR " and #" FNR-1 ", with IATA code=" myIataCode ", are distinct in Geonames, but combined in the ORI-maintained list. You could split it in ORI. Both POR:\n" myLastLine "\n" myLine) > "/dev/stderr"
			}

			# The travel-related POR will inherit from the location type associated 
			# (by ORI) to that POR. The city POR will be left untouched.
			print (myLastPK "^" myTravelLine)
			#print (myIataCode "-C" "^" myCityLine)

		} else {
			# There are two POR, exactly like in the ORI-maintained list
			print (myLastPK "^" myLastLine)
			print (myLastAltPK "^" myLine)
		}

	} else {
		# There is a single POR in Geonames for that IATA code.

		if ((length(location_type) == 1 && location_type_alt == "") || myIataCode in combined_list) {
			# There is also a single POR in the ORI-maintained list. It may be either:
			#  - A combined case ('CA'), such as NCE
			#  - A mono-typed case (e.g., 'C', 'A', 'H'), such as LON or LHR
			print (myLastPK "^" myLastLine)

		} else {
			# There are two POR in the ORI-maintained list sharing that IATA code.
			# The Geonames details will therefore be duplicated
			print (myLastPK "^" myLastLine)
			print (myLastAltPK "^" myLastLine)

			# Notification
			if (log_level >= 4) {
				print ("!! Notification: For the line #" FNR " and the '" myIataCode "' IATA code, the Geonames data had to be duplicated because the ORI-maintained list has got two entries (the location types being '" location_type_alt "' and '" location_type "') - Full line: " myLastLine) > "/dev/stderr"
			}

			# Sanity check: by construction, the location type is multi-character;
			#               an alternative location type should therefore be specified
			if (location_type_alt == "") {
				print ("!!!! Error at line #" FNR " for the '" myIataCode "' IATA code; the location type ('" location_type "') has got at least two characters, while no alternative location has been defined (check also the ORI-maintained list) - Full line: " myLastLine) > "/dev/stderr"
			}
		}
	}
}


##
#
BEGIN {
	last_iata_code = ""
	last_pk = ""
	last_pk_alt = ""
	last_full_line = ""
	last_is_city = 0
	last_is_travel = 0
	last_city_line = ""
	last_travel_line = ""
	nb_of_por = 0
	last_nb_of_por = 0
}

##
# The ../ORI/best_coordinates_known_so_far.csv data file is used, in order to specify
# the POR primary key )and its location type).
# Sample lines:
#  ARN-A^ARN^59.651944^17.918611^STO (2 single in ORI, split from combined, 1 in Geonames)
#  ARN-R^ARN^59.649463^17.929^STO
#  IES-CA^IES^51.3^13.28^IES         (1 combined in ORI, 1 in Geonames)
#  IEV-A^IEV^50.401694^30.449697^IEV (2 single in ORI, split from combined, 2 in Geonames)
#  IEV-C^IEV^50.401694^30.449697^IEV
#  KBP-A^KBP^50.345^30.894722^IEV    (1 single in ORI, 1 in Geonames)
#  LHR-A^LHR^51.4775^-0.461389^LON   (1 single in ORI, 1 in Geonames)
#  LON-C^LON^51.5^-0.1667^LON        (1 single in ORI, 1 in Geonames)
#  NCE-CA^NCE^43.658411^7.215872^NCE (1 combined in ORI, 2 in Geonames)
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^/ {

	# Primary key (combination of IATA code and location type)
	pk = $1

	# IATA code
	iata_code = $2

	# Location type
	location_type = substr (pk, 5)

	# Check whether the POR is a city. It can be a city only or, most often,
	# a combination of a city with a travel-related type (e.g., airport,
	# rail station). In some rare cases, an airport may be combined with something
	# else than a city (e.g., railway station); ARN is such an example, and
	# CDG might be another one.
	is_city = match (location_type, "[C]")

	# Travel-related type
	is_airport = match (location_type, "[A]")
	is_rail = match (location_type, "[R]")
	is_bus = match (location_type, "[B]")
	is_heliport = match (location_type, "[H]")
	is_port = match (location_type, "[P]")
	is_offpoint = match (location_type, "[O]")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port + is_offpoint

	# Sanity check
	if (length(location_type) >= 2 && is_travel == 0) {
		print ("!!!! Error at line #" FNR ", the location type ('" location_type "') is unknown - Full line: " $0) > "/dev/stderr"
	}

	# Store the location types. If there are two location types for that POR,
	# the first should be the travel-related one and the second should be the city.
	last_location_type = location_type_list[iata_code]
	if (last_location_type == "") {
		# No location type has been registered yet
		location_type_list[iata_code] = location_type

	} else {
		# A location type has already been registered
		is_last_city = match (last_location_type, "[C]")
		is_last_airport = match (last_location_type, "[A]")
		is_last_rail = match (last_location_type, "[R]")
		is_last_bus = match (last_location_type, "[B]")
		is_last_heliport = match (last_location_type, "[H]")
		is_last_port = match (last_location_type, "[P]")
		is_last_offpoint = match (last_location_type, "[O]")
		is_last_travel = is_last_airport + is_last_rail + is_last_bus + is_last_heliport + is_last_port + is_last_offpoint

		if (is_last_city == 1) {
			# The previously registered location type is a city
			location_type_list[iata_code] = location_type
			location_type_alt_list[iata_code] = last_location_type

			# Sanity check: the new location type should be travel-related
			if (is_travel == 0) {
				print ("!!!! Rare case at line #" FNR ", there are at least two location types ('" last_location_type "' and '" location_type "'), but the latter one is neither a city nor travel-related - Full line: " $0) > "/dev/stderr"
			}

		} else if (is_city == 1) {
			# The city is the new location type; the previously registered one must
			# then be travel-related
			location_type_list[iata_code] = last_location_type
			location_type_alt_list[iata_code] = location_type

			# Sanity check: the last location type should be travel-related
			if (is_last_travel == 0) {
				print ("!!!! Rare case at line #" FNR ", there are at least two location types ('" last_location_type "' and '" location_type "'), but the former one is neither a city nor travel-related - Full line: " $0) > "/dev/stderr"
			}

		} else {
			# Neither the previously registered location type nor the current one is
			# a city. So, if there is an airport, it will be registered in the first
			# position; otherwise, the alphabetical order of the location type is
			# used by construction.
			if (is_last_airport == 1) {
				location_type_list[iata_code] = last_location_type
				location_type_alt_list[iata_code] = location_type

			} else if (is_airport == 1) {
				location_type_list[iata_code] = location_type
				location_type_alt_list[iata_code] = last_location_type

			} else {
				location_type_alt_list[iata_code] = location_type
			}
		}
	}

	#
	if (is_city != 0) {
		city_list[iata_code] = 1

		if (is_travel != 0) {
			combined_list[iata_code] = 1
		}
	}

	if (is_travel != 0) {
		travel_list[iata_code] = 1
	}

	if (is_airport != 0) {
		airport_list[iata_code] = 1
	}

	if (is_rail != 0) {
		rail_list[iata_code] = 1
	}

	if (is_bus != 0) {
		bus_list[iata_code] = 1
	}

	if (is_heliport != 0) {
		heliport_list[iata_code] = 1
	}

	if (is_port != 0) {
		port_list[iata_code] = 1
	}

	if (is_offpoint != 0) {
		offpoint_list[iata_code] = 1
	}
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
#  IEV^UKKK^6300960^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.4016900^30.4497000^UA^^S^AIRP^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Kyiv Airport,...^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport
#  IEV^ZZZZ^703448^Kiev^Kiev^50.4546600^30.5238000^UA^^P^PPLC^12^^^^2514227^0^187^Europe/Kiev^2.0^3.0^2.0^2012-01-31^Kiev,...,Київ^
#  LHR^EGLL^2647216^London Heathrow Airport^London Heathrow Airport^51.4711500^-0.4564900^GB^^S^AIRP^ENG^GLA^F9^^0^0^27^Europe/London^0.0^1.0^0.0^2010-08-03^London Heathrow,...,伦敦 海斯楼 飞机场,倫敦希斯路機場^http://en.wikipedia.org/wiki/London_Heathrow_Airport
#  LON^ZZZZ^2643743^London^London^51.5085300^-0.1257400^GB^^P^PPLC^ENG^GLA^^^7556900^0^25^Europe/London^0.0^1.0^0.0^2012-06-11^City of London,...,伦敦,倫敦^
#  NCE^LFMN^6299418^Nice - Côte d'Azur^Nice - Cote d'Azur^43.6608600^7.2054000^FR^^S^AIRP^B8^06^062^06088^0^3^7^Europe/Paris^1.0^2.0^1.0^2012-02-27^Nice Airport,...^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport
#  NCE^ZZZZ^2990440^Nice^Nice^43.7031300^7.2660800^FR^^P^PPLA2^B8^06^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2011-11-02^Nice,...,Ница,尼斯^
#
/^([A-Z]{3})\^([A-Z0-9]{4})\^([0-9]{1,10})\^/ {
	#
	nb_of_por++

	# IATA code
	iata_code = $1

	# ICAO code
	icao_code = $2

	# Feature code
	fcode = $11

	#
	is_city = match (fcode, "PPL") + match (fcode, "ADM")

	is_airport = match (fcode, "AIRB") + match (fcode, "AIRF") + match (fcode, "AIRP") + match (fcode, "AIRS")
	is_rail = match (fcode, "RSTN")
	is_bus = match (fcode, "BUST")
	is_heliport = match (fcode, "AIRH")
	is_port = match (fcode, "NVB") + match (fcode, "PRT")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port

	# Store the full line
	full_line = $0
	city_line = full_line
	travel_line = full_line

	# ORI-maintained location type
	location_type = location_type_list[iata_code]
	location_type_alt = location_type_alt_list[iata_code]

	# Sanity check: the POR should be known from ORI
	if (location_type == "") {
		print ("!!!! Error at line #" FNR ", the POR with that IATA code ('" iata_code "') is not referenced in the ORI-maintained list: " full_line) > "/dev/stderr"
	}

	# New primary key, made of the IATA code and ORI-maintained location type
	pk = iata_code "-" location_type
	pk_alt = iata_code "-" location_type_alt

	if (iata_code == last_iata_code) {
		# This is (at least) the second POR sharing the same IATA code. Normally,
		# the second POR is a city, and the first POR is travel-related (e.g.,
		# airport, railway station).

		# Sanity check (there should not be more than two POR with the same IATA code)
		if (nb_of_por >= 3) {
			print ("!!!! Error at line #" FNR ", there over two POR with the same IATA code ('" iata_code "' - Last line: " full_line) > "/dev/stderr"
		}

		# Check which POR is the city, and which is the travel-related one
		if (last_is_city == 1) {
			city_line = last_full_line
			travel_line = full_line

		} else if (is_city == 1) {
			city_line = full_line
			travel_line = last_full_line

		} else {
			print ("!!!! Error for the POR #" FNR " and #" FNR-1 ", with IATA code=" iata_code ". Neither is a city. Both POR:\n" last_full_line "\n" full_line) > "/dev/stderr"
		}

		# Display the last POR
		displayPOR(iata_code, last_pk, pk, pk_alt, city_line, travel_line, nb_of_por, last_full_line, full_line)

	} else {

		# DEBUG
		# print ("[" last_iata_code "][" iata_code "] lastPK=" last_pk ", PK=" pk ", PK_Alt=" last_pk_alt ", nb_of_por=" nb_of_por ", last_nb_of_por=" last_nb_of_por)

		if (last_nb_of_por == 1) {
			# Display the last POR
			displayPOR(last_iata_code, last_pk, "", last_pk_alt, "", "", last_nb_of_por, last_full_line, "")
		}

		#
		nb_of_por = 1
	}

	# Iteration
	last_iata_code = iata_code
	last_pk = pk
	last_pk_alt = pk_alt
	last_full_line = full_line
	last_city_line = city_line
	last_travel_line = travel_line
	last_is_city = is_city
	last_is_travel = is_travel
	last_nb_of_por = nb_of_por
}

#
ENDFILE {
	#
	if (last_nb_of_por == 1) {
		# Display the last POR
		displayPOR(last_iata_code, last_pk, "", last_pk_alt, "", "", last_nb_of_por, last_full_line, "")
	}

	# DEBUG
	#displayLists()
}

