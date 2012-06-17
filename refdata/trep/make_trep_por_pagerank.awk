##
# That script just translate the IATA codes into lower case characters

{
	#
	por_code = tolower ($1)
	por_type = tolower ($2)
	page_rank = $3 * 100.0

	#
	printf (por_code "^" por_type "^")
	printf ("%12.10f", page_rank)
	printf ("\n")
}
