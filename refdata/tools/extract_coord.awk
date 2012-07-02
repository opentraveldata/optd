##
# That AWK script extract the geographical coordinates from data files.
#
# Note: the format of the input files is very specific.
#

##
# M A I N
#
{
	if (NF == 8) {
		# The corresponding IATA code exists both in Geonames and in the file
		# of best known coordinates.
		# Samples:
		#  - NCE-CA^NCE^43.6627200^7.2078700^NCE^43.658411^7.215872^NCE
		#  - IEV-A^IEV^50.4016900^30.4497000^IEV^50.401694^30.449697^IEV
		#  - IEV-C^IEV^50.4546600^30.5238000^IEV^50.401694^30.449697^IEV
		#  - CDG-A^CDG^49.0127800^2.5500000^CDG^49.012779^2.55^PAR
		#  - PAR-C^PAR^48.8534100^2.3488000^PAR^49.02^2.533^PAR

		#  [OLD] PAR^48.8534100^2.3488000^PAR-C^49.02^2.533^PAR

		# Primary key ^ IATA code ^ (Geonames) latitude ^ (Geonames) longitude
		print ($1 "^" $2 "^" $3 "^" $4)

	} else if (NF == 5) {
		# The corresponding IATA code exists only in the file of best known coordinates.
		# Samples:
		#  - XIT-R^XIT^51.42^12.42^LEJ

		# Primary key ^ IATA code ^ (ORI) latitude ^ (ORI) longitude
		print ($1 "^" $2 "^" $3 "^" $4)

	} else {
		# Unkown case
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"
	}
}
