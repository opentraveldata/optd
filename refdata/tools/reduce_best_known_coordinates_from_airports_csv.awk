####
##
##

## M A I N
{
	# IATA code
	printf ($1)

	if (NF == 3) {
		# The entry comes from the file of best coordinates. There is no 
		# corresponding entry in the ORI-maintained data file.
		# The coordinates can be copied directly (i.e., they are the best known
		# ones).
		printf ("^" $2 "^" $3)

	} else if (NF == 16) {
		# The entry comes from the ORI-maintained data file. There is no 
		# corresponding entry in the file of best coordinates.
		# The coordinates are the fields/columns #12 and #13.
		printf ("^" $12 "^" $13)

	} else {
		# The entry is a combination of both the best coordinates and of the
		# ORI-maintained data file. The best coordinates have to be used,
		# and located at the 2nd and 3rd slots (which correspond to
		# fields/columns #2 and #3 respectively).
		printf ("^" $2 "^" $3)
	}

	# End of line
	printf ("\n");

	# Increment for the next turn
	idx = idx+1
}