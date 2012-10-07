####
##
##

##
# M A I N
#
# Sample input lines:
# - NCE^LFMN^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^Nice Airport,...^43.658411^7.215872^S^AIRP^0.158985215433^^^^FR^^B8^06^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Y^Y^NCE^^EUROP^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de^Flughafen Nizza^^en^Nice Côte d'Azur International Airport^^es^Niza Aeropuerto^ps^fr^Aéroport de Nice Côte d'Azur^^en^Nice Airport^s
# - SZD-A^SZD^53.394256^-1.388486^SZD^
#
{
	# IATA code ^ location type
	printf ("%s", $1 "^" $2)

	if (NF == 6) {
		# The entry comes from the file of best coordinates. There is no 
		# corresponding entry in the ORI-maintained data file.
		# The coordinates can be copied directly (i.e., they are the best known
		# ones).
		printf ("%s", "^" $3 "^" $4)

	} else if (NF == 17) {
		# The entry comes from the ORI-maintained data file. There is no 
		# corresponding entry in the file of best coordinates.
		# The coordinates are the fields/columns #13 and #14.
		printf ("%s", "^" $13 "^" $14)

	} else {
		# The entry is a combination of both the best coordinates and of the
		# ORI-maintained data file. The best coordinates have to be used,
		# and located at the 3rd and 4th slots (which correspond to
		# fields/columns #3 and #4 respectively).
		printf ("%s", "^" $3 "^" $4)
	}

	# End of line
	printf ("%s", "\n");

	# Increment for the next turn
	idx = idx+1
}
