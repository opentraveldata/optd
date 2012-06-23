#
# AWK script to calculate the distance between two geographical points.
#
# The input data files should be formatted as required below.
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
	distance = sqrt (pow(londif * prcurt * cos(meanlat), 2) + pow((latdif*mrcurt),2))
}

#
BEGIN {
	M_PI = 4 * atan2(1,1)
	rad = 180 / M_PI
}

# Main
{

	if (NF == 8 || NF == 6) {
		# IATA code and location type
		iata_code = $1
		location_type = $2

		# The POR is specified within both input data files (e.g., Geonames
		# and the file of best known coordinates).
		lat1 = $3 / rad
		lat2 = $5 / rad
		lon1 = $4 / rad
		lon2 = $6 / rad

		# Default value
		pagerank = ""

		# Use the PageRank for that POR (point of reference) when it exists
		if (NF == 8) {
			pagerank = $8
		}

		# When the PageRank does not exist, it is set to 0.1%
		if (pagerank == "") pagerank = 0.001

		# Delegate the distance calculation
		distance_func()

		# IATA code
		printf ("%s", iata_code)

		# Distance, in km
		printf ("^%5.0f", distance/1000.0)
		
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

	} else if (NF == 4) {
		# The POR (point of reference) is not known from Geonames. So, there is no
		# difference to calculate: do nothing else here.

	} else {
		# Do nothing
		print ("!!!! For " FNR " record, there are " NF " fields, whereas 6 or 8 are expected: " $0) > "/dev/stderr"
	}

}
