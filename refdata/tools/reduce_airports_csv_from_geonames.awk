####
##
##

# Header
BEGIN {
	printf ("%s", "iata_code^icao_code^is_geonames^geonameid^name^asciiname")
	printf ("%s", "^alternatenames^latitude^longitude^fclass^fcode^country_code^cc2")
	printf ("%s", "^admin1^admin2^admin3^admin4")
	printf ("%s", "^population^elevation^gtopo30")
	printf ("%s", "^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("%s", "^is_airport^is_commercial")
	printf ("%s", "^city_code^state_code^region_code^location_type\n")
	today_date = mktime ("YYYY-MM-DD")
}

## M A I N
{
	if (NF >= 27) {
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^" $4 "^Y^" $5 "^" $6 "^" $7)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $26 "^" $2 "^" $3 "^" $12 "^" $13)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $10 "^" $11)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $14 "^" $15 "^" $16 "^" $17)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $18 "^" $19 "^" $20)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $21 "^" $22 "^" $23 "^" $24)

		# ^ Modification date
		printf ("%s", "^" $25)

		# ^ Is airport ^ Is commercial
		if ($13 == "AIRP" || $13 == "AIRH" || $13 == "AIRF" || $13 == "AIRS") {
			printf ("%s", "^Y^Z")
		} else if ($13 == "AIRB") {
			printf ("%s", "^Y^N")
		} else if ($13 == "RSTN") {
			printf ("%s", "^N^Z")
		} else if (substr ($13, 1, 3) == "PPL") {
			printf ("%s", "^N^N")
		} else {
			printf ("%s", "^N^Z")
		}

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $1 "^" $14 "^" "WORLD")

		#  ^ Location type
		if ($13 == "AIRP") {
			printf ("%s", "^A")
		} else if ($13 == "AIRH") {
			printf ("%s", "^A")
		} else if ($13 == "AIRB") {
			printf ("%s", "^A")
		} else if ($13 == "RSTN") {
			printf ("%s", "^O")
		} else if (substr ($13, 1, 3) == "PPL") {
			printf ("%s", "^C")
		} else {
			printf ("%s", "^Z")
		}

		# Print the extra alternate names
		if (NF >= 28) {
			for (fld = 28; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		#
		printf ("%s", "\n")

		# ----
		# From best known coordinates ($1 - $3)
		# (1) SQX ^ (2) -26.7816 ^ (3) -53.5035 ^
		#
		# From Geonames ($4 - $26+)
		# (4) SSOE ^ (5) 7731508 ^ (6) São Miguel do Oeste Airport ^
		# (7) Sao Miguel do Oeste Airport ^ (8) -26.7816 ^ (9) -53.5035 ^
		# (10) BR ^ (11)  ^ (12) S ^ (13) AIRP ^
		# (14) 26 ^ (15)  ^ (16)  ^ (17)  ^
		# (18) 0 ^ (19) 0 ^ (20) 655 ^ (21) America/Sao_Paulo ^
		# (22) -2.0 ^ (23) -3.0 ^ (24) -3.0 ^ (25) 2011-03-18 ^ (26) SQX,SSOE ^
		# (27) Wiki link
		# [optional] ^ (28+) Alternate name N

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"
	}
}

