##
# That script just translate the IATA codes into lower case characters

{
	#
	iata_code = tolower ($1)
	page_rank = $2 * 100.0

	#
	printf (iata_code "^")
	printf ("%12.10f", page_rank)
	printf ("\n")
}