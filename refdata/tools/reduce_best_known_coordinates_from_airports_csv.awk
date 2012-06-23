####
##
##

## M A I N
{
	# IATA code ^ location type
	printf ($1 "^" $2)

	if (NF == 4) {
		# The entry comes from the file of best coordinates. There is no 
		# corresponding entry in the ORI-maintained data file.
		# The coordinates can be copied directly (i.e., they are the best known
		# ones).
		printf ("^" $3 "^" $4)

	} else if (NF == 17) {
		# The entry comes from the ORI-maintained data file. There is no 
		# corresponding entry in the file of best coordinates.
		# The coordinates are the fields/columns #13 and #14.
		printf ("^" $13 "^" $14)

	} else {
		# The entry is a combination of both the best coordinates and of the
		# ORI-maintained data file. The best coordinates have to be used,
		# and located at the 3rd and 4th slots (which correspond to
		# fields/columns #3 and #4 respectively).
		printf ("^" $3 "^" $4)
	}

	# End of line
	printf ("\n");

	# Increment for the next turn
	idx = idx+1
}
