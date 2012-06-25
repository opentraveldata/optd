##
#
#

# Header
BEGIN {
	printf ("%s", "iata_code^icao_code^is_geonames^geonameid^name^asciiname")
	printf ("%s", "^alternatenames^latitude^longitude^fclass^fcode^country_code^cc2")
	printf ("%s", "^admin1^admin2^admin3^admin4")
	printf ("%s", "^population^elevation^gtopo30")
	printf ("%s", "^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("%s", "^is_airport^is_commercial")
	printf ("%s", "^city_code^state_code^region_code^location_type")
	printf ("%s", "^wiki_link")
	printf ("%s", "^lang_alt1^alt_name1^lang_alt2^alt_name2^lang_alt3^alt_name3")
	printf ("%s", "^lang_alt4^alt_name4^lang_alt5^alt_name5^lang_alt6^alt_name6")
	printf ("%s", "^lang_alt7^alt_name7^lang_alt8^alt_name8")
	printf ("%s", "^lang_alt9^alt_name9^lang_alt10^alt_name10")
	printf ("%s", "\n")
	today_date = mktime ("YYYY-MM-DD")
	unknown_idx = 1
}

# M A I N
{
	if (NF >= 47) {
		####
		## Both in Geonames and in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^" $6 "^Y^" $7 "^" $8 "^" $9)

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
		printf ("%s", "^" $38 "^" $47)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $37 "^" $39 "^" $41)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" substr($2, 5) "^" $29)

		# Print the extra alternate names
		if (NF >= 48) {
			for (fld = 48; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $5)
		# (1) NCE ^ (2) NCE-CA ^ (3) 43.658411 ^ (4) 7.215872 ^ (5) NCE ^

		# From Geonames ($6 - $29)
		# (6) LFMN ^ (7) 6299418 ^ (8) Nice - Côte d'Azur ^
		# (9) Nice - Cote d'Azur ^ (10) 43.6608600 ^ (11) 7.2054000 ^
		# (12) FR ^ (13)  ^ (14) S ^ (15) AIRP ^
		# (16) B8 ^ (17) 06 ^ (18) 062 ^ (19) 06088 ^
		# (20) 0 ^ (21) 3 ^ (22) 7
		# (23) Europe/Paris ^ (24) 1.0 ^ (25) 2.0 ^ (26) 1.0 ^
		# (27) 2012-02-27 ^
		# (28) Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Cote d'Azur International Airport,Côte d'Azur International Airport,Flughafen Nizza,LFMN,NCE,Niza Aeropuerto ^
		# (29) http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport ^

		# From RFD ($30 - $47)
		# (30) NCE ^ (31) CA ^ (32) NICE ^ (33) COTE D AZUR ^ (34) NICE ^
		# (35) NICE/FR:COTE D AZUR ^ (36) NICE ^ (37) NCE ^ (38) Y ^ (39) ^ (40) FR ^
		# (41) EUROP ^ (42) ITC2 ^ (43) FR052 ^
		# (44) 43.6653 ^ (45) 7.215 ^ (46)  ^ (47) Y

	} else if (NF == 23) {
		####
		## Not in Geonames
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^ZZZZ^N^0^" $11 "^" $11)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4)

		# Location type
		location_type = substr($2, 5)

		#  ^ Feat. class ^ Feat. code
		if ($14 == "Y") {
			# The POR is an airport
			printf ("%s", "^S^AIRP")
		} else if (location_type == "CA") {
			# The POR is an airport and a city, but RFD wrongly set it
			printf ("%s", "^S^AIRP")
		} else if (location_type == "C") {
			# The POR is a city
			printf ("%s", "^P^PPLC")
		} else if (location_type == "O") {
			# The POR is an off-line point, which could be a bus/railway station
			printf ("%s", "^X^XXXX")
		} else {
			# The location type can not be determined
			printf ("%s", "^Z^ZZZZ")
			print ("!!!! Warning !!!! The location type can not be determined for the record #" FNR ":") > "/dev/stderr"
			print ($0) > "/dev/stderr"
		}

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $16 "^")

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^^^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $19 "^^^")

		# ^ Modification date
		printf ("%s", "^" today_date)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $14 "^" $23)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $13 "^" $15 "^" $17)

		# ^ Location type ^ Wiki link (empty here)
		printf ("%s", "^" substr($2, 5) "^")

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $5)
		# (1) XIT ^ (2) XIT-R (3) 51.42 ^ (4) 12.42 ^ (5) LEJ ^

		# From RFD ($6 - $23)
		# (6) XIT ^ (7) R ^ (8) LEIPZIG RAIL ^ (9) LEIPZIG HBF RAIL STN ^
		# (10) LEIPZIG RAIL ^ (11) LEIPZIG/HALLE/DE:LEIPZIG HBF R ^ (12) LEIPZIG/HALLE ^
		# (13) LEJ ^ (14) Y ^ (15)  ^ (16) DE ^ (17) EUROP ^ (18) ITC2 ^
		# (19) DE040 ^ (20) 51.3 ^ (21) 12.3333 ^ (22)  ^ (23) N

	} else if (NF >= 29 && NF < 47) {
		####
		## Not in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^" $6 "^Y^" $7 "^" $8 "^" $9)

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
		if ($14 == "AIRP") {
			printf ("%s", "^Y^Z")
		} else if ($14 == "AIRH") {
			printf ("%s", "^Y^Z")
		} else if ($14 == "AIRB") {
			printf ("%s", "^Y^N")
		} else if ($14 == "RSTN") {
			printf ("%s", "^N^Z")
		} else if (substr ($14, 1, 3) == "PPL") {
			printf ("%s", "^N^N")
		} else {
			printf ("%s", "^N^Z")
		}

		# ^ City code ^ State code
		printf ("%s", "^" $1 "^" $16)

		# ^ Region code
		region_full = $23
		region = gensub ("/[A-Za-z_]+", "", "g", region_full)
		region_country = gensub ("[A-Za-z]+/", "", "1", region_full)
		gsub ("/[A-Za-z_]+", "", region_country)
		region_city = gensub ("[A-Za-z_]+/", "", "g", region_full)

		if (region == "Europe") {
			if (region_country == "Kiev") {
				printf ("%s", "^EEURO")
			} else {
				printf ("%s", "^EUROP")
			}
		} else if (region == "Africa") {
			printf ("%s", "^AFRICA")
		} else if (region == "Asia") {
			printf ("%s", "^ASIA")
		} else if (region == "Atlantic") {
			printf ("%s", "^ATLAN")
		} else if (region == "Australia") {
			printf ("%s", "^AUSTL")
		} else if (region == "America") {
			if (region_country == "Argentina") {
				printf ("%s", "^SAMER")
			} else {
				printf ("%s", "^NAMER")
			}
		} else if (region == "Indian") {
			printf ("%s", "^IOCEA")
		} else if (region == "Pacific") {
			printf ("%s", "^PACIF")
		} else {
			printf ("%s", "^ZZZZZ")
		}

		#  ^ Location type
		if ($15 == "AIRP") {
			printf ("%s", "^CA")
		} else if ($15 == "AIRH") {
			printf ("%s", "^CH")
		} else if ($15 == "AIRB") {
			printf ("%s", "^CA")
		} else if ($16 == "RSTN") {
			printf ("%s", "^R")
		} else if (substr ($15, 1, 3) == "PPL") {
			printf ("%s", "^C")
		} else {
			printf ("%s", "^Z")
		}

		# ^ Wiki link (potentially empty)
		printf ("%s", "^" $29)

		# Print the extra alternate names
		if (NF >= 30) {
			for (fld = 30; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $5)
		# (1) SQX ^ (2) SQX-CA ^ (3) -26.7816 ^ (4) -53.5035 ^ (5) SQX ^

		# From Geonames ($6 - $29)
		# (6) SSOE ^ (7) 7731508 ^ (8) São Miguel do Oeste Airport ^
		# (9) Sao Miguel do Oeste Airport ^ (10) -26.7816 ^ (11) -53.5035 ^
		# (12) BR ^ (13)  ^ (14) S ^ (15) AIRP ^
		# (16) 26 ^ (17)  ^ (18)  ^ (19)  ^
		# (20) 0 ^ (21) 0 ^ (22) 655 ^ (23) America/Sao_Paulo ^
		# (24) -2.0 ^ (25) -3.0 ^ (26) -3.0 ^ (27) 2011-03-18 ^ (28) SQX,SSOE
		# (29)  ^

	} else if (NF == 5) {
		####
		## Neither in Geonames nor in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^ZZZZ^N^0^" "UNKNOWN" unknown_idx  "^" "UNKNOWN" unknown_idx) > "ori_only_por.csv.new"

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4) > "ori_only_por.csv.new"

		#  ^ Feat. class ^ Feat. code
		printf ("%s", "^S^AIRP") > "ori_only_por.csv.new"

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" "ZZ" "^") > "ori_only_por.csv.new"

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^^^^") > "ori_only_por.csv.new"

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^") > "ori_only_por.csv.new"

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" "Europe/Greenwich" "^^^") > "ori_only_por.csv.new"

		# ^ Modification date
		printf ("%s", "^" today_date) > "ori_only_por.csv.new"

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" "Y" "^" "Y") > "ori_only_por.csv.new"

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" "ZZZ" "^" "^" "UNKOWN") > "ori_only_por.csv.new"

		#  ^ Location type ^ Wiki link (empty here)
		printf ("%s", "^" "CA" "^" "\n") > "ori_only_por.csv.new"

		# ----
		# From ORI-POR ($1 - $5)
		# (1) AAD ^ (2) AAD-CA ^ (3) 18.05 ^ (4) 30.95 ^ (5) AAD

		# -----
		# From ORI-POR ($1 - $5)
		# (1) ACO ^ (2) ACO-CA ^ (3) 46.15 ^ (4) 8.767 ^ (5) ACO

		#
		unknown_idx++

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"
	}

}
