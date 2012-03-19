####
##
##

# Header
BEGIN {
	printf ("iata_code^icao_code^is_geonames^geonameid^name^asciiname")
	printf ("^alternatenames^latitude^longitude^fclass^fcode^country_code^cc2")
	printf ("^admin1^admin2^admin3^admin4")
	printf ("^population^elevation^gtopo30")
	printf ("^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("^is_airport^is_commercial")
	printf ("^city_code^state_code^region_code^location_type\n")
	today_date = mktime ("YYYY-MM-DD")
}

## M A I N
{
	# IATA code
	printf ($1)

	if (NF == 3) {
		# The entry comes from the file of best coordinates. There is no 
		# corresponding entry in the ORI-maintained data file.
		printf ("!!!! Please add an entry for row #" FNR ", having " NF " fields: " $0 "\n") > "/dev/stderr"

	} else if (NF == 33) {
		# The entry is a combination of both the best coordinates and of the
		# ORI-maintained data file. The best coordinates have to be used,
		# and located at the 12th and 13th slots (which correspond to
		# fields/columns #14 and #15 respectively).
		#
		# ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("^" $4 "^" $5 "^" $6 "^" $7 "^" $8)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("^" $9 "^" $2 "^" $3 "^" $12 "^" $13)

		# ^ Country code ^ Alt. country codes
		printf ("^" $14 "^" $15)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^" $16 "^" $17 "^" $18 "^" $19)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^" $20 "^" $21 "^" $22)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $23 "^" $24 "^" $25 "^" $26)

		# ^ Modification date
		printf ("^" $27)

		# ^ Is airport ^ Is commercial
		printf ("^" $28 "^" $29)

		# ^ City code ^ State code ^ Region code ^ Location type
		printf ("^" $30 "^" $31 "^" $32 "^" $33)

		# ----
		# From best known coordinates ($1 - $3)
		# (1) SQX ^ (2) -26.7816 ^ (3) -53.5035 ^
		#
		# From ORI-POR ($4 - $33)
		# (4) SSOE ^ (5) Y ^ (6) 7731508 ^
		# (7) São Miguel do Oeste Airport ^ (8) Sao Miguel do Oeste Airport ^
		# (9) SQX,SSOE (10) -26.7816 ^ (11) -53.5035 ^
		# (12) S ^ (13) AIRP ^
		# (14) BR ^ (15)  ^
		# (16) 26 ^ (17)  ^ (18)  ^ (19)  ^
		# (20) 0 ^ (21) 0 ^ (22) 655 ^ (23) America/Sao_Paulo ^
		# (24) -2.0 ^ (25) -3.0 ^ (26) -3.0 ^ (27) 2011-03-18 ^
		# (28) Y ^ (29) Z ^ (30) ZZZ ^ (31) ^ (32) ZZZZZ ^ (33) A

	} else {
		printf ("!!!! Error for row #" FNR ", having " NF " fields: " $0 "\n") > "/dev/stderr"
	}

	# End of line
	printf ("\n");
}