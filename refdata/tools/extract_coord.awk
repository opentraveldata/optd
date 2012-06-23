##
# That AWK script extract the geographical coordinates from data files.
#
# Note: the format of the input files is very specific.
#

##
# M A I N
#
{
	if (NF == 6) {
		# The corresponding IATA code exists both in Geonames and in the file
		# of best known coordinates

		# IATA code ^ (Geonames) latitude ^ (Geonames) longitude
		print ($1 "^" $2 "^" $3)

	} else if (NF == 4) {
		# The corresponding IATA code exists only in the file of best known coordinates

		# IATA code ^ (ORI) latitude ^ (ORI) longitude
		print ($1 "^" $3 "^" $4)

	} else {
		# Unkown case
		printf ("!!!! Error for row #" FNR ", having " NF " fields: " $0 "\n") > "/dev/stderr"
	}
}
