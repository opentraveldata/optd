####
## That AWK script extracts the good geographical coordinates and puts them
## in a file having got the same format as the original Geonames dump file.
##
## Sample output lines:
##

# Header
BEGIN {
	printf ("%s", "pk^iata_code^icao_code^is_geonames^geonameid^name^asciiname")
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
	if (NF >= 29) {
		# Primary key
		printf ("%s", $1)

		# ^ IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $2 "^" $6 "^Y^" $7 "^" $8 "^" $9)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $28 "^" $3 "^" $4 "^" $14 "^" $15)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $12 "^" $13)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $16 "^" $17 "^" $18 "^" $19)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $20 "^" $21 "^" $22)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $23 "^" $24 "^" $25 "^" $26)

		# ^ Modification date
		printf ("%s", "^" $27)

		# ^ Is airport ^ Is commercial
		if ($15 == "AIRP" || $15 == "AIRH" || $15 == "AIRF" || $15 == "AIRS") {
			printf ("%s", "^Y^Z")
		} else if ($15 == "AIRB") {
			printf ("%s", "^Y^N")
		} else if ($15 == "RSTN") {
			printf ("%s", "^N^Z")
		} else if (substr ($15, 1, 4) == "BUST") {
			printf ("%s", "^N^Z")
		} else if (substr ($15, 1, 3) == "PPL") {
			printf ("%s", "^N^N")
		} else {
			printf ("%s", "^N^Z")
		}

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $2 "^" $16 "^" "WORLD")

		#  ^ Location type
		if ($15 == "AIRP") {
			printf ("%s", "^A")
		} else if ($15 == "AIRH") {
			printf ("%s", "^H")
		} else if ($15 == "AIRB") {
			printf ("%s", "^A")
		} else if ($15 == "RSTN") {
			printf ("%s", "^O")
		} else if (substr ($15, 1, 4) == "BUST") {
			printf ("%s", "^B")
		} else if (substr ($15, 1, 3) == "PPL") {
			printf ("%s", "^C")
		} else {
			printf ("%s", "^Z")
		}

		# Print the extra alternate names
		if (NF >= 30) {
			for (fld = 30; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		#
		printf ("%s", "\n")

		# ----
		# From ORI-maintained list of best known coordinates ($1 - $4)
		# (1) SQX-CA ^ (2) SQX ^ (3) -26.7816 ^ (4) -53.5035 ^
		#
		# From Geonames ($5 - $29+)
		# (5) SQX ^ (6) SSOE ^ (7) 7731508 ^ (8) São Miguel do Oeste Airport ^
		# (9) Sao Miguel do Oeste Airport ^ (10) -26.7816 ^ (11) -53.5035 ^
		# (12) BR ^ (13)  ^ (14) S ^ (15) AIRP ^
		# (16) 26 ^ (17)  ^ (18)  ^ (19)  ^
		# (20) 0 ^ (21) 0 ^ (22) 655 ^ (23) America/Sao_Paulo ^
		# (24) -2.0 ^ (25) -3.0 ^ (26) -3.0 ^ (27) 2011-03-18 ^ (28) SQX,SSOE ^
		# (29) Wiki link
		# [optional] ^ (30+) Alternate name N

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"
	}
}

