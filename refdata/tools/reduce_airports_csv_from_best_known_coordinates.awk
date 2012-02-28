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
		# Twelve dummy fields/columns have to be filled, so as to reach
		# 16 fields/columns in all.
		printf ("^UNKNOWN" idx "^UNKNOWN" idx "^UNKNOWN" idx)
		printf ("/ZZ^ZZZ^Y^^ZZ^ZZZZZ^ITZ1^ZZ^" $2 "^" $3 "^0^N^CA")

	} else if (NF == 16) {
		# The entry comes from the ORI-maintained data file. There is no 
		# corresponding entry in the file of best coordinates.
		# Nothing has to be changed, as the 16 fields are already here.
		for (i=2; i<=16; i=i+1) {
			printf ("^" $i)
		}

	} else {
		# The entry is a combination of both the best coordinates and of the
		# ORI-maintained data file. The best coordinates have to be used,
		# and located at the 12th and 13th slots (which correspond to
		# fields/columns #14 and #15 respectively).
		for (i=4; i<=13; i=i+1) {
			printf ("^" $i)
		}

		printf ("^" $2 "^" $3)

		for (i=16; i<=18; i=i+1) {
			printf ("^" $i)
		}
	}

	# End of line
	printf ("\n");

	# Increment for the next turn
	idx = idx+1
}