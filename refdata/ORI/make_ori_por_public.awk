##
#
#

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
	unknown_idx = 1
}

# M A I N
{
	if (NF == 43) {
		####
		## Both in Geonames and in RFD
		####
		#
		# ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ($1 "^" $4 "^Y^" $5 "^" $6 "^" $7)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("^" $26 "^" $2 "^" $3 "^" $12 "^" $13)

		# ^ Country code ^ Alt. country codes
		printf ("^" $10 "^" $11)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^" $14 "^" $15 "^" $16 "^" $17)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^" $18 "^" $19 "^" $20)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $21 "^" $22 "^" $23 "^" $24)

		# ^ Modification date
		printf ("^" $25)

		# ^ Is airport ^ Is commercial
		printf ("^" $33 "^" $42)

		# ^ City code ^ State code ^ Region code
		printf ("^" $32 "^" $34 "^" $36)

		# ^ Location type
		printf ("^" $43)

		# End of line
		printf ("\n")

		# ----
		# From ORI-POR ($1 - $3)
		# (1) NCE ^ (2) 43.658411 ^ (3) 7.215872

		# From Geonames ($4 - $26)
		# (4) LFMN ^ (5) 6299418 ^ (6) Nice - Côte d'Azur ^
		# (7) Nice - Cote d'Azur ^ (8) 43.6608600 ^ (9) 7.2054000 ^
		# (10) FR ^ (11)  ^ (12) S ^ (13) AIRP ^
		# (14) B8 ^ (15) 06 ^ (16) 062 ^ (17) 06088 ^
		# (18) 0 ^ (19) 3 ^ (20) 7
		# (21) Europe/Paris ^ (22) 1.0 ^ (23) 2.0 ^ (24) 1.0 ^
		# (25) 2012-02-27 ^
		# (26) Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Cote d'Azur International Airport,Côte d'Azur International Airport,Flughafen Nizza,LFMN,NCE,Niza Aeropuerto

		# From RFD ($27 - $43)
		# (27) NICE ^ (28) ^ (29) NICE ^ (30) NICE/FR:COTE D AZUR ^
		# (31) NICE ^ (32) NCE ^ (33) Y ^ (34) ^ (35) FR ^ (36) EUROP ^
		# (37) ITC2 ^ (38) FR052 ^
		# (39) 43.6653 ^ (40) 7.215 ^ (41)  ^ (42) Y ^ (43) CA

	} else if (NF == 20) {
		####
		## Not in Geonames
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ($1 "^ZZZZ^N^0^" $7 "^" $7)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("^^" $2 "^" $3)

		#  ^ Feat. class ^ Feat. code
		if ($10 == "Y") {
			# The POR is an airport
			printf ("^S^AIRP")
		} else if ($20 == "CA") {
			# The POR is an airport and a city, but RFD wrongly set it
			printf ("^S^AIRP")
		} else if ($20 == "C") {
			# The POR is a city
			printf ("^P^PPLC")
		} else if ($20 == "O") {
			# The POR is an off-line point, which could be a bus/railway station
			printf ("^X^XXXX")
		} else {
			# The location type can not be determined
			printf ("^Z^ZZZZ")
			printf ("!!!! Warning !!!! The location type can not be determined for the record #" FNR ":\n") > "/dev/stderr"
			printf ($0 "\n") > "/dev/stderr"
		}

		# ^ Country code ^ Alt. country codes
		printf ("^" $12 "^")

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^^^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $15 "^^^")

		# ^ Modification date
		printf ("^" today_date)

		# ^ Is airport ^ Is commercial
		printf ("^" $10 "^" $19)

		# ^ City code ^ State code ^ Region code
		printf ("^" $9 "^" $11 "^" $13)

		# ^ Location type
		printf ("^" $20)

		# End of line
		printf ("\n")

		# ----
		# From ORI-POR ($1 - $3)
		# (1) XCG ^ (2) 43.6667 ^ (3) 7.15 ^

		# From RFD ($4 - $20)
		# (4) CAGNES SUR MER ^ (5) ^ (6) CAGNES SUR MER ^
		# (7) CAGNES SUR MER/FR:CAGNES SUR M ^ (8) CAGNES SUR MER ^
		# (9) XCG ^ (10) Y ^ (11)  ^ (12) FR ^ (13) EUROP ^ (14) ITC2 ^
		# (15) FR052 ^ (16) 43.6667 ^ (17) 7.15 ^ (18)  ^ (19) N ^ (20) O

		# ----
		# From ORI-POR ($1 - $3)
		# (1) AAG ^ (2) -22.87 ^ (13) -43.27 ^

		# From RFD ($4 - $20)
		# (4) ARAPOTI ^ (5)  ^ (6) ARAPOTI ^ (7) ARAPOTI/PR/BR ^
		# (8) ARAPOTI ^ (9) AAG ^ (10) Y ^ (11) PR ^ (12) BR ^ (13) SAMER ^
		# (14) ITC1 ^ (15) BR015 ^ (16) -22.8667 ^ (17) -43.2667 ^ (18)  ^
		# (19) N ^ (20) CA

	} else if (NF == 26) {
		####
		## Not in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ($1 "^" $4 "^Y^" $5 "^" $6 "^" $7)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("^" $26 "^" $2 "^" $3 "^" $12 "^" $13)

		# ^ Country code ^ Alt. country codes
		printf ("^" $10 "^" $11)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^" $14 "^" $15 "^" $16 "^" $17)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^" $18 "^" $19 "^" $20)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $21 "^" $22 "^" $23 "^" $24)

		# ^ Modification date
		printf ("^" $25)

		# ^ Is airport ^ Is commercial
		if ($13 == "AIRP") {
			printf ("^Y^Z")
		} else if ($13 == "AIRH") {
			printf ("^Y^Z")
		} else if ($13 == "AIRB") {
			printf ("^Y^N")
		} else if ($13 == "RSTN") {
			printf ("^N^Z")
		} else if (substr ($13, 1, 3) == "PPL") {
			printf ("^N^N")
		} else {
			printf ("^N^Z")
		}

		# ^ City code ^ State code
		printf ("^" $1 "^" $14)

		# ^ Region code
		region_full = $21
		region = gensub ("/[A-Za-z_]+", "", "g", region_full)
		region_country = gensub ("[A-Za-z]+/", "", "1", region_full)
		gsub ("/[A-Za-z_]+", "", region_country)
		region_city = gensub ("[A-Za-z_]+/", "", "g", region_full)

		if (region == "Europe") {
			if (region_country == "Kiev") {
				printf ("^EEURO")
			} else {
				printf ("^EUROP")
			}
		} else if (region == "Africa") {
			printf ("^AFRICA")
		} else if (region == "Asia") {
			printf ("^ASIA")
		} else if (region == "Atlantic") {
			printf ("^ATLAN")
		} else if (region == "Australia") {
			printf ("^AUSTL")
		} else if (region == "America") {
			if (region_country == "Argentina") {
				printf ("^SAMER")
			} else {
				printf ("^NAMER")
			}
		} else if (region == "Indian") {
			printf ("^IOCEA")
		} else if (region == "Pacific") {
			printf ("^PACIF")
		} else {
			printf ("^ZZZZZ")
		}

		#  ^ Location type
		if ($13 == "AIRP") {
			printf ("^A")
		} else if ($13 == "AIRH") {
			printf ("^A")
		} else if ($13 == "AIRB") {
			printf ("^A")
		} else if ($13 == "RSTN") {
			printf ("^O")
		} else if (substr ($13, 1, 3) == "PPL") {
			printf ("^C")
		} else {
			printf ("^Z")
		}

		# End of line
		printf ("\n")

		# ----
		# From ORI-POR ($1 - $3)
		# (1) SQX ^ (2) -26.7816 ^ (3) -53.5035 ^

		# From Geonames ($4 - $26)
		# (4) SSOE ^ (5) 7731508 ^ (6) São Miguel do Oeste Airport ^
		# (7) Sao Miguel do Oeste Airport ^ (8) -26.7816 ^ (9) -53.5035 ^
		# (10) BR ^ (11)  ^ (12) S ^ (13) AIRP ^
		# (14) 26 ^ (15)  ^ (16)  ^ (17)  ^
		# (18) 0 ^ (19) 0 ^ (20) 655 ^ (21) America/Sao_Paulo ^
		# (22) -2.0 ^ (23) -3.0 ^ (24) -3.0 ^ (25) 2011-03-18 ^ (26) SQX,SSOE

	} else if (NF == 3) {
		####
		## Neither in Geonames nor in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ($1 "^ZZZZ^N^0^" "UNKNOWN" unknown_idx  "^" "UNKNOWN" unknown_idx) > "ori_only_por.csv.new"

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("^^" $2 "^" $3) > "ori_only_por.csv.new"

		#  ^ Feat. class ^ Feat. code
		printf ("^S^AIRP") > "ori_only_por.csv.new"

		# ^ Country code ^ Alt. country codes
		printf ("^" "ZZ" "^") > "ori_only_por.csv.new"

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^^^^") > "ori_only_por.csv.new"

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^^^") > "ori_only_por.csv.new"

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" "Europe/Greenwich" "^^^") > "ori_only_por.csv.new"

		# ^ Modification date
		printf ("^" today_date) > "ori_only_por.csv.new"

		# ^ Is airport ^ Is commercial
		printf ("^" "Y" "^" "Y") > "ori_only_por.csv.new"

		# ^ City code ^ State code ^ Region code
		printf ("^" "ZZZ" "^" "^" "UNKOWN") > "ori_only_por.csv.new"

		#  ^ Location type
		printf ("^" "CA" "\n") > "ori_only_por.csv.new"

		# ----
		# From ORI-POR ($1 - $3)
		# (1) AAD ^ (2) 18.05 ^ (3) 30.95

		# -----
		# From ORI-POR ($1 - $3)
		# (1) ACO ^ (2) 46.15 ^ (3) 8.767

		#
		unknown_idx++

	} else {
		printf ("!!!! Error for row #" FNR ", having " NF " fields: " $0 "\n") > "/dev/stderr"
	}

}
