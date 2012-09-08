##
#
# Header
BEGIN {
	printf ("pk^iata_code^xapian_docid^icao_code^is_geonames^geonameid")
	printf ("^latitude^longitude^fclass^fcode^country_code^cc2")
	printf ("^admin1^admin2^admin3^admin4")
	printf ("^population^elevation^gtopo30")
	printf ("^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("^is_airport^is_commercial")
	printf ("^city_code^state_code^region_code^location_type^wiki_link\n")
}

##
# M A I N
#
# ORI-maintained list of POR (points of reference)
#
# Sample (partial) lines:
# IEV-A^IEV^UKKK^Y^6300960^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^Aehroport «Kiev» (Zhuljany),IEV ...^50.401694^30.449697^S^AIRP^UA^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Y^Y^IEV^^EURAS^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en^Kyiv Zhuliany International Airport^^en^Kyiv International Airport^^en^Kyiv Airport^s^en^Kiev International Airport^^uk^Міжнародний аеропорт «Київ» (Жуляни)^^ru^Аэропорт «Киев» (Жуляны)^^ru^Международный аеропорт «Киев» (Жуляни)^
# IEV-C^IEV^ZZZZ^Y^703448^Kiev^Kiev^Chijv ...^50.401694^30.449697^P^PPLC^UA^^12^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-08-18^N^N^IEV^^EURAS^C^http://en.wikipedia.org/wiki/Kiev^eo^Kievo^
#
{
	# (1) Primary key (IATA code, location type)
	pk = tolower ($1)
	printf ("%s", pk)

	# (2) IATA code
	iata_code = tolower ($2)
	printf ("%s", "^" iata_code)

	# Xapian Document ID (set arbitrarily to 0 here)
	printf ("%s", "^0")

	# ^ (3) ICAO code ^ (4) Is Geonames ^ (5) Geonames ID
	for (i=3; i<=5; i++) {
		# detail = $i
		detail = tolower ($i)
		printf ("^%s", detail)
	}

	# Do not dump the names (ascii name, UTF name, alternate names),
	# which are the fields from #6 to #8 (included) and beyond #34 (included)

	# ^ (9) Latitude ^ (10) Longitude ^ ... ^ (33) Wiki link
	for (i=9; i<=33; i++) {
		# detail = $i
		detail = tolower ($i)
		printf ("^%s", detail)
	}

	# End of line
	printf ("%s", "\n")
}
