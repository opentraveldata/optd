####
##
##

## M A I N
{
	# IATA code
	printf($1)

	# Beginning of the Geonames fields
	for (i = 5; i <= 7; i++) {
		printf ("^" $i)
	}

	# Geographical coordinates (latitude, longitude)
	printf ("^" $2 "^" $3)

	# Remaining of the Geonames fields
	printf ("^" $10 "^" $11 "^" $12 "^" $13 "^" $14 "\n")
}
