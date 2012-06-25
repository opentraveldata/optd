##
# That AWK script extract the geographical coordinates from data files.
#
# Note: the format of the input files is very specific.
#

##
# M A I N
#
{
	if (NF == 7) {
		# The corresponding IATA code exists both in Geonames and in the file
		# of best known coordinates
		# Samples:
		#  - NCE^43.6608600^7.2054000^NCE-CA^43.658411^7.215872^NCE
		#  - IEV^50.4016900^30.4497000^IEV-A^50.401694^30.449697^IEV
		#  - IEV^50.4016900^30.4497000^IEV-C^50.401694^30.449697^IEV
		#  - CDG^49.0127800^2.5500000^CDG-A^49.012779^2.55^PAR
		#  - PAR^48.8534100^2.3488000^PAR-C^49.02^2.533^PAR

		# IATA code ^ (Geonames) latitude ^ (Geonames) longitude
		print ($1 "^" $2 "^" $3)

	} else if (NF == 5) {
		# The corresponding IATA code exists only in the file of best known coordinates
		# Samples:
		#  - XIT^XIT-R^51.42^12.42^LEJ

		# IATA code ^ (ORI) latitude ^ (ORI) longitude
		print ($1 "^" $3 "^" $4)

	} else {
		# Unkown case
		printf ("!!!! Error for row #" FNR ", having " NF " fields: " $0 "\n") > "/dev/stderr"
	}
}
