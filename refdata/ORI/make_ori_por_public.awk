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
	if (NF >= 45) {
		####
		## Both in Geonames and in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^" $5 "^Y^" $6 "^" $7 "^" $8)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $27 "^" $3 "^" $4 "^" $13 "^" $14)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $11 "^" $12)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $15 "^" $16 "^" $17 "^" $18)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $19 "^" $20 "^" $21)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $22 "^" $23 "^" $24 "^" $25)

		# ^ Modification date
		printf ("%s", "^" $26)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $36 "^" $45)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $35 "^" $37 "^" $39)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" $2 "^" $28)

		# Print the extra alternate names
		if (NF >= 46) {
			for (fld = 46; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $4)
		# (1) NCE ^ (2) CA ^ (3) 43.658411 ^ (4) 7.215872

		# From Geonames ($5 - $26)
		# (5) LFMN ^ (6) 6299418 ^ (7) Nice - Côte d'Azur ^
		# (8) Nice - Cote d'Azur ^ (9) 43.6608600 ^ (10) 7.2054000 ^
		# (11) FR ^ (12)  ^ (13) S ^ (14) AIRP ^
		# (15) B8 ^ (16) 06 ^ (17) 062 ^ (18) 06088 ^
		# (19) 0 ^ (20) 3 ^ (21) 7
		# (22) Europe/Paris ^ (23) 1.0 ^ (24) 2.0 ^ (25) 1.0 ^
		# (26) 2012-02-27 ^
		# (27) Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Cote d'Azur International Airport,Côte d'Azur International Airport,Flughafen Nizza,LFMN,NCE,Niza Aeropuerto ^
		# (28) http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport ^

		# From RFD ($28 - $44)
		# (29) CA ^ (30) NICE ^ (31) COTE D AZUR ^ (32) NICE ^ (33) NICE/FR:COTE D AZUR ^
		# (34) NICE ^ (35) NCE ^ (36) Y ^ (37) ^ (38) FR ^ (39) EUROP ^
		# (40) ITC2 ^ (41) FR052 ^
		# (42) 43.6653 ^ (43) 7.215 ^ (44)  ^ (45) Y

	} else if (NF == 21) {
		####
		## Not in Geonames
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^ZZZZ^N^0^" $9 "^" $9)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4)

		#  ^ Feat. class ^ Feat. code
		if ($12 == "Y") {
			# The POR is an airport
			printf ("%s", "^S^AIRP")
		} else if ($5 == "CA") {
			# The POR is an airport and a city, but RFD wrongly set it
			printf ("%s", "^S^AIRP")
		} else if ($5 == "C") {
			# The POR is a city
			printf ("%s", "^P^PPLC")
		} else if ($5 == "O") {
			# The POR is an off-line point, which could be a bus/railway station
			printf ("%s", "^X^XXXX")
		} else {
			# The location type can not be determined
			printf ("%s", "^Z^ZZZZ")
			print ("!!!! Warning !!!! The location type can not be determined for the record #" FNR ":") > "/dev/stderr"
			print ($0) > "/dev/stderr"
		}

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $14 "^")

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^^^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $17 "^^^")

		# ^ Modification date
		printf ("%s", "^" today_date)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $12 "^" $21)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $11 "^" $13 "^" $15)

		# ^ Location type ^ Wiki link (empty here)
		printf ("%s", "^" $5 "^")

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $4)
		# (1) XIT ^ (2) R (3) 51.42 ^ (4) 12.42 ^

		# From RFD ($5 - $21)
		# (5) R ^ (6) LEIPZIG RAIL ^ (7) LEIPZIG HBF RAIL STN ^ (8) LEIPZIG RAIL ^
		# (9) LEIPZIG/HALLE/DE:LEIPZIG HBF R ^ (10) LEIPZIG/HALLE ^
		# (11) LEJ ^ (12) Y ^ (13)  ^ (14) DE ^ (15) EUROP ^ (16) ITC2 ^
		# (17) DE040 ^ (18) 51.3 ^ (19) 12.3333 ^ (20)  ^ (21) N

		# ----
		# From ORI-POR ($1 - $4)
		# (1) AAG ^ (2) -22.87 ^ (13) -43.27 ^

		# From RFD ($5 - $21)
		# (5) CA ^ (6) ARAPOTI ^ (7)  ^ (8) ARAPOTI ^ (9) ARAPOTI/PR/BR ^
		# (10) ARAPOTI ^ (11) AAG ^ (12) Y ^ (13) PR ^ (14) BR ^ (15) SAMER ^
		# (16) ITC1 ^ (17) BR015 ^ (18) -22.8667 ^ (19) -43.2667 ^ (20)  ^ (21) N

	} else if (NF >= 28 && NF < 45) {
		####
		## Not in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^" $5 "^Y^" $6 "^" $7 "^" $8)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $27 "^" $3 "^" $4 "^" $13 "^" $14)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $11 "^" $12)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $15 "^" $16 "^" $17 "^" $18)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $19 "^" $20 "^" $21)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $22 "^" $23 "^" $24 "^" $25)

		# ^ Modification date
		printf ("%s", "^" $26)

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
		printf ("%s", "^" $1 "^" $15)

		# ^ Region code
		region_full = $22
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
		if ($14 == "AIRP") {
			printf ("%s", "^CA")
		} else if ($14 == "AIRH") {
			printf ("%s", "^CH")
		} else if ($14 == "AIRB") {
			printf ("%s", "^CA")
		} else if ($14 == "RSTN") {
			printf ("%s", "^R")
		} else if (substr ($14, 1, 3) == "PPL") {
			printf ("%s", "^C")
		} else {
			printf ("%s", "^Z")
		}

		# ^ Wiki link (potentially empty)
		printf ("%s", "^" $28)

		# Print the extra alternate names
		if (NF >= 29) {
			for (fld = 29; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $4)
		# (1) SQX ^ (2) CA ^ (3) -26.7816 ^ (4) -53.5035 ^

		# From Geonames ($5 - $27)
		# (5) SSOE ^ (6) 7731508 ^ (7) São Miguel do Oeste Airport ^
		# (8) Sao Miguel do Oeste Airport ^ (9) -26.7816 ^ (10) -53.5035 ^
		# (11) BR ^ (12)  ^ (13) S ^ (14) AIRP ^
		# (15) 26 ^ (16)  ^ (17)  ^ (18)  ^
		# (19) 0 ^ (20) 0 ^ (21) 655 ^ (22) America/Sao_Paulo ^
		# (23) -2.0 ^ (24) -3.0 ^ (25) -3.0 ^ (26) 2011-03-18 ^ (27) SQX,SSOE
		# (28)  ^

	} else if (NF == 4) {
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
		# From ORI-POR ($1 - $4)
		# (1) AAD ^ (2) CA ^ (3) 18.05 ^ (4) 30.95

		# -----
		# From ORI-POR ($1 - $4)
		# (1) ACO ^ (2) CA ^ (3) 46.15 ^ (4) 8.767

		#
		unknown_idx++

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) > "/dev/stderr"
	}

}
