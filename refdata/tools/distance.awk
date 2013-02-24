#
# AWK script to calculate the distance between two geographical points.
#

##
# More explicit name for the power function
function pow (b, p) {
	return b^p
}

##
# Calculate the azimuth, giving the relative direction, from the first POR (point
# of reference) to the second one
function azim_func() {
	latdif = lat1 - lat2
	londif = lon1 - lon2
	meanlat = (lat1 + lat2)/2
	
	A = 2 * atan2 (londif * ((prcurt/mrcurt) * (cos(meanlat))), latdif)
	B = londif * (sin(meanlat))
	Az = (A-B)/2
	if (londif > 0 && latdif < 0) Az += M_PI
	if (londif < 0 && latdif < 0) Az += M_PI
	if (londif < 0 && latdif > 0) Az += 2*M_PI
	
	return Az*rad
}

##
# Calculate the geographical (great circle) distance
function distance_func() {
	latdif = lat1 - lat2
	londif = lon1 - lon2
	meanlat = (lat1 + lat2)/2
	
	a = 6377276.345
	b = 6356075.4131
	e = sqrt ((a*a - b*b) / (a*a))
	mrcurt = ( a * (1 - (e*e))) / pow((1-((e*e) * pow(sin(meanlat),2))), 1.5)
	prcurt = a / sqrt (1-pow((e * sin(meanlat)), 2))
	distance = sqrt (pow(londif * prcurt * cos(meanlat), 2) \
					 + pow((latdif*mrcurt),2))
}

##
# States whether that location type corresponds to a travel-related POR
function isTravel(myLocationType) {
	is_airport = match (myLocationType, "A")
	is_rail = match (myLocationType, "R")
	is_bus = match (myLocationType, "B")
	is_heliport = match (myLocationType, "H")
	is_port = match (myLocationType, "P")
	is_ground = match (myLocationType, "G")
	is_offpoint = match (myLocationType, "O")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port	\
		+ is_ground + is_offpoint

	return is_travel
}

##
# Retrieve the PageRank value for that POR
function getPageRank(myIataCode, myLocationType, myGeonamesID) {
	is_city = match (myLocationType, "C")
	is_tvl = isTravel(myLocationType)
	
	if (is_city != 0) {
		page_rank = city_list[myIataCode]

	} else if (is_tvl != 0) {
		page_rank = tvl_list[myIataCode]

	} else {
		page_rank = 0.001
	}

	return page_rank
}


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "distance.awk"

	M_PI = 4 * atan2(1,1)
	rad = 180 / M_PI
}


##
# File of PageRank values.
#
# Note that the location types of that file are not the same as the ones
# in the best_coordinates_known_so_far.csv file. Indeed, the location types
# take a value from three possible ones: 'C', 'A' or 'CA', where 'A' actually
# means travel-related rather than airport. There are distinct entries for
# the city and for the corresponding travel-related POR, only when there are
# several travel-related POR serving the city.
#
# In the best_coordinates_known_so_far.csv file, instead, there are distinct
# entries when Geonames has got itself distinct entries.
#
# For instance:
#  * NCE has got:
#    - 2 distinct entries in the best_coordinates_known_so_far.csv file:
#       NCE-A-6299418^NCE^43.658411^7.215872^NCE^
#       NCE-C-2990440^NCE^43.70313^7.26608^NCE^
#    - 1 entry in the file of PageRank values:
#       NCE-CA^NCE^0.161281957529
#  * IEV has got:
#    - 2 distinct entries in the best_coordinates_known_so_far.csv file:
#       IEV-A-6300960^IEV^50.401694^30.449697^IEV^
#       IEV-C-703448^IEV^50.401694^30.449697^IEV^
#    - 2 entries in the file of PageRank values:
#       IEV-C^IEV^0.109334523229
#       IEV-A^IEV^0.0280192004497
#
# Sample input lines:
#   LON-C^LON^1.0
#   PAR-C^PAR^0.994632137197
#   NYC-C^NYC^0.948221089373
#   CHI-C^CHI^0.768305897463
#   ATL-A^ATL^0.686723208248
#   ATL-C^ATL^0.686723208248
#   NCE-CA^NCE^0.158985215433
#   ORD-A^ORD^0.677280625337
#   CDG-A^CDG^0.647060165878
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^([0-9.]{1,15})$/ {
	# Primary key (IATA code and location pseudo-code)
	pk = $1

	# IATA code
	iata_code = substr (pk, 1, 3)

	# Location pseudo-type ('C' means City, but 'A' means any related to travel,
	# e.g., airport, heliport, port, bus or train station)
	por_type = substr (pk, 5)

	# Sanity check
	if (iata_code != $2) {
		print ("[" awk_file "] !!! Error at recrod #" FNR \
			   ": the IATA code ('" iata_code			  \
			   "') should be equal to the field #2 ('" $2 \
			   "'), but is not. The whole line " $0) > error_stream
	}

	# Check whether it is a city
	is_city = match (por_type, "C")

	# Check whether it is travel-related
	is_tvl = match (por_type, "A")

	# PageRank value
	pr_value = $3

	# Store the PageRank value for that POR
	if (is_city != 0) {
		city_list[iata_code] = pr_value
	}
	if (is_tvl != 0) {
		tvl_list[iata_code] = pr_value
	}
}


##
# Main
#  * POR in both the list of best known coordinates and Geonames,
#    with a PageRank:
#    - (11) NCE-CA-6299418^NCE^43.658411^7.215872^NCE^^NCE^43.66272^7.20787^NCE^0.158985215433
#  * POR in both the list of best known coordinates and Geonames,
#    without a PageRank:
#    -  (9) AAC-CA-6297289^AAC^31.073333^33.835833^AAC^^AAC^31.07333^33.83583
#  * POR only in the list of best known coordinates, with a PageRank
#    -  (8) AJL-CA-0^AJL^23.746603^92.802767^AJL^^AJL^0.00868396886294
#  * POR only in the list of best known coordinates, without a PageRank
#    -  (6) XIT-R-0^XIT^51.42^12.42^LEJ^
#
/^([A-Z]{3})-([A-Z]{0,2})-([0-9]{1,10})\^([A-Z]{3})\^([0-9.+-]{0,12})\^/ {

	# Primary key (IATA code, location type and Geonames ID)
	pk = $1

	# Location type (extracted from the primary key)
	location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$",	\
							"\\2", "g", pk)

	# Geonames ID
	geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$",	\
						  "\\3",	"g", pk)

	# IATA code
	iata_code = $2
	
	# PageRank value
	page_rank = getPageRank(iata_code, location_type, geonames_id)

	# Best known geographical coordinates (fields #3 and #4)
    if (NF >= 8) {
		lat1 = $3 / rad
		lon1 = $4 / rad
	} else {
		lat1 = 0
		lon1 = 0
	}

	# Geonames geographical coordinates, when existing (fields #8 and #9)
	if (NF == 11 || NF == 9) {
		lat2 = $8 / rad
		lon2 = $9 / rad
	} else {
		lat2 = 0
		lon2 = 0
	}

	# For now, calculate the distance only when the POR exists in both
	# input files
    if (NF == 11 || NF == 9) {
		# Delegate the distance calculation
		distance_func()

		# IATA code
		printf ("%s", iata_code "-")

		# Location type
		printf ("%2s", location_type)

		# Distance, in km
		printf ("^%6.0f", distance/1000.0)
		
		# PageRank (the maximum being 100%, i.e., 1.0, usually for ORD/Chicago)
		printf ("^%21.20f", page_rank)

		# Popularity, in number of passengers
		# printf ("^%9.0f", pagerank)

		# Distance x PageRank
		printf ("^%8.0f", page_rank*distance)

		# Distance x popularity
		# printf ("^%8.0f", popularity*distance/1000000.0)

		# End-of-line
		printf ("%s", "\n")

	} else if (NF == 8 || NF == 6) {
		# The POR (point of reference) is not known from Geonames.
		# So, there is no difference to calculate: do nothing else here.

	} else {
		# Do nothing
		print ("!!!! For " FNR " record, there are " NF \
			   " fields, whereas 6, 8, 9 or 11 are expected: " $0) \
			> "/dev/stderr"
	}

}
