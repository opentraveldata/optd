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
	if (NF >= 27) {
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ($1 "^" $5 "^Y^" $6 "^" $7 "^" $8)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("^" $27 "^" $2 "^" $3 "^" $13 "^" $14)

		# ^ Country code ^ Alt. country codes
		printf ("^" $11 "^" $12)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^" $15 "^" $16 "^" $17 "^" $18)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^" $19 "^" $20 "^" $21)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $22 "^" $23 "^" $24 "^" $25)

		# ^ Modification date
		printf ("^" $26)

		# ^ Is airport ^ Is commercial
		if ($14 == "AIRP" || $14 == "AIRH" || $14 == "AIRF" || $14 == "AIRS") {
			printf ("^Y^Z")
		} else if ($14 == "AIRB") {
			printf ("^Y^N")
		} else if ($14 == "RSTN") {
			printf ("^N^Z")
		} else if (substr ($14, 1, 3) == "PPL") {
			printf ("^N^N")
		} else {
			printf ("^N^Z")
		}

		# ^ City code ^ State code ^ Region code
		printf ("^" $1 "^" $15 "^" "WORLD")

		#  ^ Location type
		if ($14 == "AIRP") {
			printf ("^A")
		} else if ($14 == "AIRH") {
			printf ("^A")
		} else if ($14 == "AIRB") {
			printf ("^A")
		} else if ($14 == "RSTN") {
			printf ("^O")
		} else if (substr ($14, 1, 3) == "PPL") {
			printf ("^C")
		} else {
			printf ("^Z")
		}

		# Print the extra alternate names
		if (NF >= 28) {
			for (fld = 28; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		#
		printf ("\n")

		# ----
		# From best known coordinates ($1 - $3)
		# (1) SQX ^ (2) -26.7816 ^ (3) -53.5035 ^
		#
		# From Geonames ($4 - $27+)
		# (4) SQX ^ (5) SSOE ^ (6) 7731508 ^ (7) São Miguel do Oeste Airport ^
		# (8) Sao Miguel do Oeste Airport ^ (9) -26.7816 ^ (10) -53.5035 ^
		# (11) BR ^ (12)  ^ (13) S ^ (14) AIRP ^
		# (15) 26 ^ (16)  ^ (17)  ^ (18)  ^
		# (19) 0 ^ (20) 0 ^ (21) 655 ^ (22) America/Sao_Paulo ^
		# (23) -2.0 ^ (24) -3.0 ^ (25) -3.0 ^ (26) 2011-03-18 ^ (27) SQX,SSOE
		# [optional] ^ (28+) Alternate name N

	} else {
		printf ("!!!! Error for row #" FNR ", having " NF " fields: " $0 "\n") > "/dev/stderr"
	}
}

