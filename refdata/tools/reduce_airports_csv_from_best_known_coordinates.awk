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

	} else if (NF >= 35) {
		# The entry is a combination of both the best coordinates and of the
		# ORI-maintained data file. The best coordinates have to be used,
		# and located at the 3rd and 4th slots (which correspond to
		# fields/columns #3 and #4 respectively).
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^" $5 "^" $6 "^" $7 "^" $8 "^" $9)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $10 "^" $3 "^" $4 "^" $13 "^" $14)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $15 "^" $16)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $17 "^" $18 "^" $19 "^" $20)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $21 "^" $22 "^" $23)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $24 "^" $25 "^" $26 "^" $27)

		# ^ Modification date
		printf ("%s", "^" $28)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $29 "^" $30)

		# ^ City code ^ State code ^ Region code ^ Location type
		printf ("%s", "^" $31 "^" $32 "^" $33 "^" $34)

		# ^ Wiki link
		printf ("%s", "^" $35)

		# Alternate names
		for (idx = 36; idx <= NF; idx++) {
			printf ("%s", "^" $idx)
		}

		# ----
		# From best known coordinates ($1 - $4)
		# (1) SQX ^ (2) A  ^ (3) -26.7816 ^ (4) -53.5035 ^
		#
		# From ORI-POR ($4 - $33)
		# (5) SSOE ^ (6) Y ^ (7) 7731508 ^
		# (8) São Miguel do Oeste Airport ^ (9) Sao Miguel do Oeste Airport ^
		# (10) SQX,SSOE (11) -26.7816 ^ (12) -53.5035 ^
		# (13) S ^ (14) AIRP ^
		# (15) BR ^ (16)  ^
		# (17) 26 ^ (18)  ^ (19)  ^ (20)  ^
		# (21) 0 ^ (22) 0 ^ (23) 655 ^ (24) America/Sao_Paulo ^
		# (25) -2.0 ^ (26) -3.0 ^ (27) -3.0 ^ (28) 2011-03-18 ^
		# (29) Y ^ (30) Z ^ (31) ZZZ ^ (32) ^ (33) ZZZZZ ^ (34) A ^ (35) 

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
		# (1) ZYT ^ (2) R  ^ (3) 50.92 ^ (4) 5.783 ^
		#
		# From ORI-POR ($5 - $34)
		# (5) ZZZZ ^ (6) N ^ (7) 0 ^ (8) MAASTRICHT/NL:RAILWAY STATION ^
		# (9) MAASTRICHT/NL:RAILWAY STATION ^ (10)  ^
		# (11) 50.92 ^ (12) 5.783 ^
		# (13) S ^ (14) AIRP ^
		# (15) NL ^ (16)  ^
		# (17)  ^ (18)  ^ (19)  ^ (20)  ^
		# (21)  ^ (22)  ^ (23)  ^ (24) NL082 ^ (25) ^ (26) ^ (27) ^
		# (28) -1 ^ (29) Y ^ (30) N ^ (31) MST ^ (32) ^ (33) EUROP ^ (34) R

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"
	}

	# End of line
	printf ("\n");
}
