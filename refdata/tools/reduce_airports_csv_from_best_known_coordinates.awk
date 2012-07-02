####
##
##

# Header
BEGIN {
	printf ("%s", "iata_code^icao_code^is_geonames^geonameid^name^asciiname")
	printf ("%s", "^alternatenames^latitude^longitude^fclass^fcode")
	printf ("%s", "^country_code^cc2^admin1^admin2^admin3^admin4")
	printf ("%s", "^population^elevation^gtopo30")
	printf ("%s", "^timezone^gmt_offset^dst_offset^raw_offset")
	printf ("%s", "^moddate^is_airport^is_commercial")
	printf ("%s", "^city_code^state_code^region_code^location_type")
	printf ("%s", "^wiki_link")
	printf ("%s", "^lang_alt1^alt_name1^lang_alt2^alt_name2^lang_alt3^alt_name3")
	printf ("%s", "^lang_alt4^alt_name4^lang_alt5^alt_name5^lang_alt6^alt_name6")
	printf ("%s", "^lang_alt7^alt_name7^lang_alt8^alt_name8^lang_alt9^alt_name9")
	printf ("%s", "^lang_alt10^alt_name10\n")
	today_date = mktime ("YYYY-MM-DD")
}

## M A I N
{

	if (NF == 4) {
		# The entry comes from the file of best coordinates. There is no 
		# corresponding entry in the ORI-maintained data file.
		print ("!!!! Please add an entry for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"

	} else if (NF >= 36) {
		# The entry is a combination of both the best coordinates and of the
		# ORI-maintained data file. The best coordinates have to be used,
		# and located at the 3rd and 4th slots (which correspond to
		# fields/columns #3 and #4 respectively).
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^" $6 "^" $7 "^" $8 "^" $9 "^" $10)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $11 "^" $3 "^" $4 "^" $14 "^" $15)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $16 "^" $17)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $18 "^" $19 "^" $20 "^" $21)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $22 "^" $23 "^" $24)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $25 "^" $26 "^" $27 "^" $28)

		# ^ Modification date
		printf ("%s", "^" $29)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $30 "^" $31)

		# ^ City code ^ State code ^ Region code ^ Location type
		printf ("%s", "^" $32 "^" $33 "^" $34 "^" $35)

		# ^ Wiki link
		printf ("%s", "^" $36)

		# Alternate names
		for (idx = 37; idx <= NF; idx++) {
			printf ("%s", "^" $idx)
		}

		# ----
		# From best known coordinates ($1 - $4)
		# (1) SQX ^ (2) SQX-CA ^ (3) -26.7816 ^ (4) -53.5035 ^
		#
		# From ORI-POR ($5 - $36)
		# (5) SQX ^ (6) SSOE ^ (7) Y ^ (8) 7731508 ^
		# (9) São Miguel do Oeste Airport ^ (10) Sao Miguel do Oeste Airport ^
		# (11) SQX,SSOE (12) -26.7816 ^ (13) -53.5035 ^
		# (14) S ^ (15) AIRP ^
		# (16) BR ^ (17)  ^
		# (18) 26 ^ (19)  ^ (20)  ^ (21)  ^
		# (22) 0 ^ (23) 0 ^ (24) 655 ^ (25) America/Sao_Paulo ^
		# (26) -2.0 ^ (27) -3.0 ^ (28) -3.0 ^ (29) 2011-03-18 ^
		# (30) N ^ (31) Z ^ (32) SQX ^ (33) 26 ^ (34) NAMER ^ (35) CA ^ (36) 
		# [optional] ^ (37+) alternate names

	} else if (NF == 34) {
		# The entry is a combination of both the best coordinates and of the
		# RFD-maintained data file. The best coordinates have to be used,
		# and located at the 3rd and 4th slots (which correspond to
		# fields/columns #3 and #4 respectively).

		# IATA code
		printf ("%s", $1)

		for (idx = 5; idx <= NF; idx++) {
			printf ("%s", "^" $idx)
		}	

		# ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		#printf ("%s", "^" $5 "^" "N" "^" "0" "^" $8 "^" $8)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		#printf ("%s", "^" "^" $3 "^" $4 "^" $13 "^" $14)

		# ^ Country code ^ Alt. country codes
		#printf ("%s", "^" $15 "^" $16)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		#printf ("%s", "^" $17 "^" $18 "^" $19 "^" $20)

		# ^ Population ^ Elevation ^ gtopo30
		#printf ("%s", "^" $21 "^" $22 "^" $23)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		#printf ("%s", "^" $24 "^" $25 "^" $26 "^" $27)

		# ^ Modification date
		#printf ("%s", "^" "2012-01-01")

		# ^ Is airport ^ Is commercial
		#printf ("%s", "^" $29 "^" $30)

		# ^ City code ^ State code ^ Region code ^ Location type
		#printf ("%s", "^" $31 "^" $32 "^" $33 "^" $34)

		# ----
		# From best known coordinates ($1 - $4)
		# (1) ZYT ^ (2) ZYT-R  ^ (3) 50.92 ^ (4) 5.783 ^
		#
		# From ORI-POR ($5 - $34)
		# (5) MST ^ (6) ZZZZ ^ (7) N ^ (8) 0 ^ (9) MAASTRICHT/NL:RAILWAY STATION ^
		# (10) MAASTRICHT/NL:RAILWAY STATION ^ (11)  ^
		# (12) 50.92 ^ (13) 5.783 ^
		# (14) S ^ (15) AIRP ^
		# (16) NL ^ (17)  ^
		# (18)  ^ (19)  ^ (20)  ^ (21)  ^
		# (22)  ^ (23)  ^ (24)  ^ (25) NL082 ^ (26) ^ (27) ^ (28) ^
		# (29) -1 ^ (30) Y ^ (31) N ^ (32) MST ^ (33) ^ (34) EUROP ^ (35) R ^ (36) 

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"
	}

	# End of line
	printf ("\n");
}
