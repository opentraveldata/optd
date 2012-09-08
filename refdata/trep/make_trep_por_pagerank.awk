##
# That script just translate the IATA codes into lower case characters

##
# M A I N
#
# ORI-maintained list of PageRank values for POR (points of reference)
#
# Sample (partial) lines:
# IEV-C^IEV^0.120642749046
# IEV-A^IEV^0.0117988033216
#
{
	# Primary key (IATA code and location type)
	pk = tolower ($1)

	# IATA code
	iata_code = tolower ($2)

	# PageRank, translated into a percentage number (%)
	page_rank = $3 * 100.0

	#
	printf ("%s", pk "^" iata_code "^")
	printf ("%12.10f", page_rank)
	printf ("%s", "\n")
}
