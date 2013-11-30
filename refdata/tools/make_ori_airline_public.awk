##
# That AWK script re-formats the full details of airlines
# derived from a few sources:
#  * Amadeus ORI-maintained lists of:
#    * [Future] Best known airlines:        ori_airline_best_known_so_far.csv
#    * Alliance memberships:                ori_airline_alliance_membership.csv
#    * [Future] No longer valid airlines:   ori_airline_no_longer_valid.csv
#    * [Future] Nb of flight-dates:         ref_airline_nb_of_flights.csv
#  * Amadeus RFD (Referential Data):        dump_from_crb_airline.csv
#  * [Future] Geonames list of airlines:    dump_from_geonames.csv
#
# Sample output lines:
# *A^^*A^0^Star Alliance^^^
# *O^^*O^0^Oneworld^^^
# *S^^*S^0^Skyteam^^^
# AF^AFR^AF^57^Air France^Air France^Skyteam^Member
# AFR^AFR^AF^57^Air France^Air France^Skyteam^Member
# BA^BAW^BA^125^British Airways^British A/W^OneWorld^Member
# BAW^BAW^BA^125^British Airways^British A/W^OneWorld^Member
# DLH^DLH^LH^220^Lufthansa^Lufthansa^Star Alliance^Member
# LH^DLH^LH^220^Lufthansa^Lufthansa^Star Alliance^Member
# EZY^EZY^U2^0^Easyjet^Easyjet^^
# U2^EZY^U2^0^Easyjet^Easyjet^^
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "make_ori_airline_public.awk"

	# Generated file for name differences
	if (air_name_diff_file == "") {
		air_name_diff_file = "ori_airline_diff_w_alc.csv"
	}

	# Header
	printf ("%s", "unified_code^3char_code^2char_code^num_code")
	printf ("%s", "^name^name2")
	printf ("%s", "^alliance_code^alliance_status")
	printf ("%s", "\n")

	#
	today_date = mktime ("YYYY-MM-DD")
	unknown_idx = 1
}

##
# ORI-maintained list of alliance memberships
#
# Sample input lines:
# alliance_name^alliance_type^airline_iata_code_2c^airline_name
# Skyteam^Member^AF^Air France
# OneWorld^Member^BA^British Airways
# Star Alliance^Member^LH^Lufthansa
/^([A-Za-z ]+)\^([A-Za-z]+)\^([*A-Z0-9]{2})\^([A-Za-z0-9 ]+)$/ {
	# Alliance name
	alliance_name = $1

	# Alliance membership type
	alliance_type = $2

	# Airline IATA 2-character code
	air_code_2c = $3

	# Airline Name
	air_name = $4

	# Sanity check
	if (air_alliance_all_names[air_code_2c] != "") {
		print ("[" awk_file "][" FNR "] !!!! Error, '" air_name			\
			   "' airline (" air_code_2c ") already registered for the " \
			   air_alliance_all_names[air_code_2c] " alliance.\n"		\
			   "Full line: " $0) > error_stream
	}

	# Register the alliance membership details
	air_alliance_types[air_code_2c] = alliance_type
	air_alliance_all_names[air_code_2c] = alliance_name
	air_alliance_air_names[air_code_2c] = air_name

	# DEBUG
	# print ("Airline: " air_name " (" air_code_2c ") => Alliance: " \
	#	   alliance_name " (" alliance_type ")")
}

##
# Aggregated content from Amadeus RFD
#
# Sample input lines:
# *A^^*A^0^Star Alliance^
# *O^^*O^0^Oneworld^
# *S^^*S^0^Skyteam^
# AF^AFR^AF^57^Air France^Air France
# AFR^AFR^AF^57^Air France^Air France
# BA^BAW^BA^125^British Airways^British A/W
# BAW^BAW^BA^125^British Airways^British A/W
# DLH^DLH^LH^220^Lufthansa^Lufthansa
# LH^DLH^LH^220^Lufthansa^Lufthansa
#
/^([*A-Z0-9]{2,3})\^([A-Z]{3})?\^([*A-Z0-9]{2})\^([0-9]+)\^/ {

	if (NF == 6) {
		# Primary key
		pk = $1

		# IATA 3-character code
		iata_code_3c = $2

		# IATA 2-character code
		iata_code_2c = $3

		# Numeric code
		numeric_code = $4

		# Names
		air_name = $5
		air_name_alt = $6

		# Alliance details
		alliance_type = air_alliance_types[iata_code_2c] 
		alliance_name = air_alliance_all_names[iata_code_2c]

		# Alliance name from the ORI-maintained file of alliance membership
		air_name_from_alliance = air_alliance_air_names[iata_code_2c]

		# Unified code ^ IATA 3-char-code ^ IATA 2-char-code ^ Numeric code
		printf ("%s", pk "^" iata_code_3c "^" iata_code_2c "^" numeric_code)

		# ^ Name ^ Alternate name
		printf ("%s", "^" air_name "^" air_name_alt)

		# ^ Alliance name ^ Alliance membership type
		printf ("%s", "^" alliance_name "^" alliance_type)

		# Sanity check
		if (air_name_from_alliance != "" && air_name != air_name_from_alliance) {
			print (iata_code_2c "^" iata_code_3c			\
				   "^" air_name "^" air_name_from_alliance) \
				> air_name_diff_file
		}

		# End of line
		printf ("%s", "\n")

	} else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
	}

}

END {
	# DEBUG
}
