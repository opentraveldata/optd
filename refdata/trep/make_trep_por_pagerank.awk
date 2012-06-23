##
# That script just translate the IATA codes into lower case characters

##
# M A I N
{
	# IATA code
	por_code = tolower ($1)

	# Location type (e.g., 'CA', 'C', 'A', 'O' and 'R')
	por_type = tolower ($2)

	# PageRank, translated into a percentage number (%)
	page_rank = $3 * 100.0

	#
	printf ("%s", por_code "^" por_type "^")
	printf ("%12.10f", page_rank)
	printf ("%s", "\n")
}
