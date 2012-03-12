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
	printf ("^city_code^state_code^region_code^continent_code^location_type\n")
	today_date = mktime ("YYYY-MM-DD")
}

# M A I N
{
	# IATA code
	printf ($1)

	if (NF == 56) {
		####
		## Both in Geonames and in RFD
		####
		#
		# ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("^" $17 "^Y^" $18 "^" $19 "^" $20)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("^" $39 "^" $12 "^" $13 "^" $25 "^" $26)

		# ^ Country code ^ Alt. country codes
		printf ("^" $23 "^" $24)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^" $27 "^" $28 "^" $29 "^" $30)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^" $31 "^" $32 "^" $33)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $34 "^" $35 "^" $36 "^" $37)

		# ^ Modification date
		printf ("^" $38)

		# ^ Is airport ^ Is commercial
		printf ("^" $46 "^" $55)

		# ^ City code ^ State code ^ Region code ^ Continent code
		printf ("^" $45 "^" $47 "^" $49 "^" $50)

		# ^ Location type
		printf ("^" $56)

		# ----
		# From ORI-POR ($1 - $16)
		# (1) NCE ^ (2) NICE ^ (3) NICE ^ (4) NICE/FR:COTE D AZUR ^ (5) NCE ^
		# (6) Y ^ (7)  ^ (8) FR ^ (9) EUROP ^ (10) ITC2 ^ (11) FR052 ^
		# (12) 43.658411 ^ (13) 7.215872 ^ (14) 0 ^ (15) Y ^ (16) CA

		# From Geonames ($17 - $39)
		# (17) LFMN ^ (18) 6299418 ^ (19) Nice - Côte d'Azur ^
		# (20) Nice - Cote d'Azur ^ (21) 43.6608600 ^ (22) 7.2054000 ^
		# (23) FR ^ (24)  ^ (25) S ^ (26) AIRP ^
		# (27) B8 ^ (28) 06 ^ (29) 062 ^ (30) 06088 ^
		# (31) 0 ^ (32) 3 ^ (33) 7
		# (34) Europe/Paris ^ (35) 1.0 ^ (36) 2.0 ^ (37) 1.0 ^
		# (38) 2012-02-27 ^
		# (39) Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Cote d'Azur International Airport,Côte d'Azur International Airport,Flughafen Nizza,LFMN,NCE,Niza Aeropuerto

		# From RFD ($40 - $56)
		# (40) NICE ^ (41) ^ (42) NICE ^ (43) NICE/FR:COTE D AZUR ^
		# (44) NICE ^ (45) NCE ^ (46) Y ^ (47) ^ (48) FR ^ (49) EUROP ^
		# (50) ITC2 ^ (51) FR052 ^
		# (52) 43.6653 ^ (53) 7.215 ^ (54)  ^ (55) Y ^ (56) CA

	} else if (NF == 33) {
		####
		## Not in Geonames
		####
		#
		# ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("^ZZZZ^N^0^" $4 "^" $4)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("^^" $12 "^" $13)

		#  ^ Feat. class ^ Feat. code
		if ($6 == "Y") {
			# The POR is an airport
			printf ("^S^AIRP")
		} else if ($16 == "C") {
			# The POR is a city
			printf ("^P^PPLC")
		} else if ($16 == "O") {
			# The POR is an off-line point, which could be a bus/railway station
			printf ("^X^XXXX")
		} else {
			# The location type can not be determined
			printf ("^Z^ZZZZ")
			printf ("!!!! Warning !!!! The location type can not be determined for the record #" FNR ":\n") > "/dev/stderr"
			printf ($0 "\n") > "/dev/stderr"
		}

		# ^ Country code ^ Alt. country codes
		printf ("^" $8 "^")

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^^^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $11 "^^^")

		# ^ Modification date
		printf ("^" today_date)

		# ^ Is airport ^ Is commercial
		printf ("^" $6 "^" $15)

		# ^ City code ^ State code ^ Region code ^ Continent code
		printf ("^" $5 "^" $7 "^" $9 "^" $10)

		# ^ Location type
		printf ("^" $16)

		# ----
		# From ORI-POR ($1 - $16)
		# (1) XCG ^ (2) CAGNES SUR MER ^ (3) CAGNES SUR MER ^
		# (4) CAGNES SUR MER/FR:CAGNES SUR M ^ (5) XCG ^ (6) Y ^ (7)  ^ (8) FR ^
		# (9) EUROP ^ (10) ITC2 ^ (11) FR052 ^ (12) 43.6667 ^ (13) 7.15 ^
		# (14) 0 ^ (15) N ^ (16) O ^

		# From RFD ($17 - $33)
		# (17) CAGNES SUR MER ^ (18) ^ (19) CAGNES SUR MER ^
		# (20) CAGNES SUR MER/FR:CAGNES SUR M ^ (21) CAGNES SUR MER ^
		# (22) XCG ^ (23) Y ^ (24)  ^ (25) FR ^ (26) EUROP ^ (27) ITC2 ^
		# (28) FR052 ^ (29) 43.6667 ^ (30) 7.15 ^ (31)  ^ (32) N ^ (33) O

		# ----
		# From ORI-POR ($1 - $16)
		# (1) AAG ^ (2) ARAPOTI ^ (3) ARAPOTI ^ (4) ARAPOTI/PR/BR ^ (5) AAG ^
		# (6) Y ^ (7) PR ^ (8) BR ^ (9) SAMER ^ (10) ITC1 ^ (11) BR015 ^
		# (12) -22.87 ^ (13) -43.27 ^ (14) 0 ^ (15) N ^ (16) CA ^

		# From RFD ($17 - $33)
		# (17) ARAPOTI ^ (18)  ^ (19) ARAPOTI ^ (20) ARAPOTI/PR/BR ^
		# (21) ARAPOTI ^ (22) AAG ^ (23) Y ^ (24) PR ^ (25) BR ^ (26) SAMER ^
		# (27) ITC1 ^ (28) BR015 ^ (29) -22.8667 ^ (30) -43.2667 ^ (31)  ^
		# (32) N ^ (33) CA

	} else if (NF == 39) {
		####
		## Not in RFD
		####
		#
		# ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("^" $17 "^Y^" $18 "^" $19 "^" $20)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("^" $39 "^" $12 "^" $13 "^" $25 "^" $26)

		# ^ Country code ^ Alt. country codes
		printf ("^" $23 "^" $24)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^" $27 "^" $28 "^" $29 "^" $30)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^" $31 "^" $32 "^" $33)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $34 "^" $35 "^" $36 "^" $37)

		# ^ Modification date
		printf ("^" $38)

		# ^ Is airport ^ Is commercial
		if ($26 == "AIRP") {
			printf ("^Y^Z")
		} else if ($26 == "AIRH") {
			printf ("^Y^Z")
		} else if ($26 == "AIRB") {
			printf ("^Y^N")
		} else if ($26 == "RSTN") {
			printf ("^N^Z")
		} else if (substr ($26, 1, 3) == "PPL") {
			printf ("^N^N")
		} else {
			printf ("^N^Z")
		}

		# ^ City code ^ State code ^ Region code ^ Continent code
		printf ("^" $5 "^" $7 "^" $9 "^" $10)

		#  ^ Location type
		if ($26 == "AIRP") {
			printf ("^A")
		} else if ($26 == "AIRH") {
			printf ("^A")
		} else if ($26 == "AIRB") {
			printf ("^A")
		} else if ($26 == "RSTN") {
			printf ("^O")
		} else if (substr ($26, 1, 3) == "PPL") {
			printf ("^C")
		} else {
			printf ("^Z")
		}

		# ----
		# From ORI-POR ($1 - $16)
		# (1) SQX ^ (2) UNKNOWN8299 ^ (3) UNKNOWN8299 ^ (4) UNKNOWN8299/ZZ ^
		# (5) ZZZ ^ (6) Y ^ (7)  ^ (8) ZZ ^ (9) ZZZZZ ^ (10) ITZ1 ^ (11) ZZ ^
		# (12) -26.7816 ^ (13) -53.5035 ^ (14) 0 ^ (15) N ^ (16) CA ^

		# From Geonames ($17 - $39)
		# (17) SSOE ^ (18) 7731508 ^ (19) São Miguel do Oeste Airport ^
		# (20) Sao Miguel do Oeste Airport ^ (21) -26.7816 ^ (22) -53.5035 ^
		# (23) BR ^ (24)  ^ (25) S ^ (26) AIRP ^
		# (27) 26 ^ (28)  ^ (29)  ^ (30)  ^
		# (31) 0 ^ (32) 0 ^ (33) 655 ^ (34) America/Sao_Paulo ^
		# (35) -2.0 ^ (36) -3.0 ^ (37) -3.0 ^ (38) 2011-03-18 ^ (39) SQX,SSOE

	} else if (NF == 16) {
		####
		## Neither in Geonames nor in RFD
		####
		#
		# ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("^ZZZZ^N^0^" $4 "^" $4)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("^^" $12 "^" $13)

		#  ^ Feat. class ^ Feat. code
		printf ("^S^AIRP")

		# ^ Country code ^ Alt. country codes
		printf ("^" $8 "^")

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("^^^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("^" $11 "^^^")

		# ^ Modification date
		printf ("^" today_date)

		# ^ Is airport ^ Is commercial
		printf ("^" $6 "^" $15)

		# ^ City code ^ State code ^ Region code ^ Continent code
		printf ("^" $5 "^" $7 "^" $9 "^" $10)

		#  ^ Location type
		printf ("^" $16)

		# ----
		# From ORI-POR ($1 - $16)
		# (1) AAD ^ (2) AD DABBAH ^ (3) AD DABBAH ^ (4) AD DABBAH/SD ^ (5) AAD ^
		# (6) Y ^ (7)  ^ (8) SD ^ (9) AFRIC ^ (10) ITC2 ^ (11) SD172 ^
		# (12) 18.05 ^ (13) 30.95 ^ (14) 0 ^ (15) N ^ (16) CA

		# -----
		# From ORI-POR ($1 - $16)
		# (1) ACO ^ (2) UNKNOWN86 ^ (3) UNKNOWN86 ^ (4) UNKNOWN86/ZZ ^ (5) ZZZ ^
		# (6) Y ^ (7)  ^ (8) ZZ ^ (9) ZZZZZ ^ (10) ITZ1 ^ (11) ZZ ^
		# (12) 46.15 ^ (13) 8.767 ^ (14) 0 ^ (15) N ^ (16) CA

	} else {
		printf ("!!!! Error for row #" FNR ", having " NF " fields: " $0 "\n") > "/dev/stderr"
	}

	#
	printf ("\n")
}
