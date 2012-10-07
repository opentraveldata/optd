#
# AWK script to calculate the distance between two geographical points.
#

# More explicit name for the power function
function pow (b, p) {
	return b^p
}

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

#
BEGIN {
	M_PI = 4 * atan2(1,1)
	rad = 180 / M_PI
}

##
# Main
{

#  * POR in both the list of best known coordinates and Geonames,
#    with a PageRank:
#    - (11) NCE-CA^NCE^43.658411^7.215872^NCE^^NCE^43.66272^7.20787^NCE^0.158985215433
#  * POR in both the list of best known coordinates and Geonames,
#    without a PageRank:
#    -  (9) AAC-CA^AAC^31.073333^33.835833^AAC^^AAC^31.07333^33.83583
#  * POR only in the list of best known coordinates, with a PageRank
#    -  (8) AJL-CA^AJL^23.746603^92.802767^AJL^^AJL^0.00868396886294
#  * POR only in the list of best known coordinates, without a PageRank
#    -  (6) XIT-R^XIT^51.42^12.42^LEJ^

	# Primary key (IATA code - location type)
	pk = $1
	iata_code = substr ($1, 1, 3)
	location_type = substr ($1, 5)
	
	# Default PageRank value (i.e., 0.1%)
	pagerank = 0.001

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

	# The PageRank value, when existing, is the last field of the line (i.e.,
	# field #11 when POR is in both input files, or field #8 when POR is only
	# in the list of best known coordinates)
    if (NF == 11 || NF == 8) {
		pagerank = $NF
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
		printf ("^%21.20f", pagerank)

		# Popularity, in number of passengers
		# printf ("^%9.0f", pagerank)

		# Distance x PageRank
		printf ("^%8.0f", pagerank*distance)

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
