##
#
# Header
BEGIN {
	printf ("iata_code^xapian_docid^icao_code^is_geonames^geonameid")
	printf ("^latitude^longitude^fclass^fcode^country_code^cc2")
	printf ("^admin1^admin2^admin3^admin4")
	printf ("^population^elevation^gtopo30")
	printf ("^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("^is_airport^is_commercial")
	printf ("^city_code^state_code^region_code^location_type^wiki_link\n")
}

## M A I N
{
	# (1) IATA code
	iata_code = tolower ($1)
	printf (iata_code)

	# Xapian Document ID (0)
	printf ("^0")

	# ^ (2) ICAO code ^ (3) Is Geonames ^ (4) Geonames ID
	for (i=2; i<5; i++) {
		# detail = $i
		detail = tolower ($i)
		printf ("^%s", detail)
	}

	# Do not dump the names (ascii name, UTF name, alternate names),
	# which are the fields from $5 to $7 (included)

	# ^ (8) Latitude ^ (9) Longitude ^ ... ^ (32) Wiki link
	for (i=8; i<=32; i++) {
		# detail = $i
		detail = tolower ($i)
		printf ("^%s", detail)
	}

	# End of line
	printf ("\n")
}
