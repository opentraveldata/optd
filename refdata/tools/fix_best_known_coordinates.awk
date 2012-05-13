##
# That script is used by two distinct use case:
#  * 1. In order to replace the geographical coordinates, only when
#       known by Geonames.
#  * 2. In order to fix the geographical coordinates of the pristine
#       ORI-maintained list of best known POR coordinates.

{

	if (NF == 24) {
		# First use case. The POR is known by Geonames.

		# IATA code
		printf ($1)

		# The geographical coordinates are fields #6 and #7
		printf ("^" $6 "^" $7)

		#
		printf ("\n")

	} else if (NF == 5) {
		# Second use case. The coordinates have been fixed.

		# IATA code
		printf ($1)

		# The geographical coordinates are fields #7 and #7
		printf ("^" $2 "^" $3)

		#
		printf ("\n")

	} else if (NF == 3) {
		# Second use case. The coordinates have not been fixed.

		# IATA code
		printf ($1)

		# The geographical coordinates are fields #7 and #7
		printf ("^" $2 "^" $3)

		#
		printf ("\n")

	} else if (NF == 1) {
		# First use case. The POR is not known by Geonames.

	} else {
		# Error
		printf ("!!!! Error !!!! The line contains " NF " fields: " $0) > "/dev/stderr"
	}

}
