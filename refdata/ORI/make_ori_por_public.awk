##
#
#

# Header
BEGIN {
	printf ("%s", "iata_code^icao_code^is_geonames^geonameid^name^asciiname")
	printf ("%s", "^alternatenames^latitude^longitude^fclass^fcode")
	printf ("%s", "^country_code^cc2^admin1^admin2^admin3^admin4")
	printf ("%s", "^population^elevation^gtopo30")
	printf ("%s", "^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("%s", "^is_airport^is_commercial")
	printf ("%s", "^city_code^state_code^region_code^location_type")
	printf ("%s", "^wiki_link")
	printf ("%s", "^lang_alt1^alt_name1^lang_alt2^alt_name2^lang_alt3^alt_name3")
	printf ("%s", "^lang_alt4^alt_name4^lang_alt5^alt_name5^lang_alt6^alt_name6")
	printf ("%s", "^lang_alt7^alt_name7^lang_alt8^alt_name8")
	printf ("%s", "^lang_alt9^alt_name9^lang_alt10^alt_name10")
	printf ("%s", "^lang_alt11^alt_name11^lang_alt12^alt_name12")
	printf ("%s", "^lang_alt13^alt_name13^lang_alt14^alt_name14")
	printf ("%s", "^lang_alt15^alt_name15^lang_alt16^alt_name16")
	printf ("%s", "^lang_alt17^alt_name17^lang_alt18^alt_name18")
	printf ("%s", "^lang_alt19^alt_name19^lang_alt20^alt_name20")
	printf ("%s", "\n")
	today_date = mktime ("YYYY-MM-DD")
	unknown_idx = 1
}

# M A I N
{

	# When the 31st field is a IATA code, it means that the POR is in
	# both Geonames and RFD.
	is_31st_fld_iata = match ($31, "[A-Z]{3}")
	is_31st_fld_lang = match ($31, "[a-z0-9]{2,3}")

	if (NF >= 48 && is_31st_fld_iata == 1) {
		####
		## Both in Geonames and in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $2 "^" $7 "^Y^" $8 "^" $9 "^" $10)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $29 "^" $3 "^" $4 "^" $15 "^" $16)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $13 "^" $14)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $17 "^" $18 "^" $19 "^" $20)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $21 "^" $22 "^" $23)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $24 "^" $25 "^" $26 "^" $27)

		# ^ Modification date
		printf ("%s", "^" $28)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $39 "^" $48)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $38 "^" $40 "^" $42)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" substr($1, 5) "^" $30)

		# Print the extra alternate names
		if (NF >= 49) {
			for (fld = 49; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $5)
		# (1) NCE-CA ^ (2) NCE ^ (3) 43.658411 ^ (4) 7.215872 ^ (5) NCE ^

		# From Geonames ($6 - $30)
		# (6) NCE ^ (7) LFMN ^ (8) 6299418 ^
		# (9) Nice Côte d'Azur International Airport ^
		# (10) Nice Cote d'Azur International Airport ^
		# (11) 43.66272 ^ (12) 7.20787 ^
		# (13) FR ^ (14)  ^ (15) S ^ (16) AIRP ^
		# (17) B8 ^ (18) 06 ^ (19) 062 ^ (20) 06088 ^
		# (21) 0 ^ (22) 3 ^ (23) -9999
		# (24) Europe/Paris ^ (25) 1.0 ^ (26) 2.0 ^ (27) 1.0 ^
		# (28) 2012-06-30 ^
		# (29) Aeroport de Nice Cote d'Azur, ...,Niza Aeropuerto ^
		# (30) http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport ^

		# From RFD ($31 - $48)
		# (31) NCE ^ (32) CA ^ (33) NICE ^ (34) COTE D AZUR ^ (35) NICE ^
		# (36) NICE/FR:COTE D AZUR ^ (37) NICE ^ (38) NCE ^
		# (39) Y ^ (40)  ^ (41) FR ^ (42) EUROP ^ (43) ITC2 ^ (44) FR052 ^
		# (45) 43.6653 ^ (46) 7.215 ^ (47)  ^ (48) Y

		# [optional] From Geonames alternate names ($49+)
		# (49) ^ en (50) ^ Nice Airport
		# (51) ^ en (52) ^ Nice Côte d'Azur International Airport

	} else if (NF == 23) {
		####
		## Not in Geonames
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $2 "^ZZZZ^N^0^" $11 "^" $11)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4)

		# Location type
		location_type = substr ($1, 5)

		#  ^ Feat. class ^ Feat. code
		is_city = match (location_type, "C")
		is_offpoint = match (location_type, "O")
		is_airport = match (location_type, "A")
		is_heliport = match (location_type, "H")
		is_railway = match (location_type, "R")
		is_bus = match (location_type, "B")
		is_port = match (location_type, "P")
		is_ground = match (location_type, "G")
		if (is_airport != 0) {
			# The POR is an airport. Note that it takes precedence over the
			# city, when the POR is both an airport and a city. 
			printf ("%s", "^S^AIRP")
		} else if (is_heliport != 0) {
			# The POR is an heliport
			printf ("%s", "^S^AIRH")
		} else if (is_railway != 0) {
			# The POR is a railway station
			printf ("%s", "^S^RSTN")
		} else if (is_bus != 0) {
			# The POR is a bus station
			printf ("%s", "^S^BUSTN")
		} else if (is_port != 0) {
			# The POR is a (maritime) port
			printf ("%s", "^S^PORT")
		} else if (is_ground != 0) {
			# The POR is a ground station
			printf ("%s", "^S^XXXX")
		} else if (is_city != 0) {
			# The POR is (only) a city
			printf ("%s", "^P^PPLC")
		} else if (is_offpoint != 0) {
			# The POR is an off-line point, which could be a bus/railway station,
			# or even a city/village.
			printf ("%s", "^X^XXXX")
		} else {
			# The location type can not be determined
			printf ("%s", "^Z^ZZZZ")
			print ("!!!! Warning !!!! The location type cannot be determined" \
				   " for the record #" FNR ":") > "/dev/stderr"
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
		printf ("%s", "^" location_type "^")

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $5)
		# (1) XIT-R ^ (2) XIT (3) 51.42 ^ (4) 12.42 ^ (5) LEJ ^

		# From RFD ($6 - $23)
		# (6) XIT ^ (7) R ^ (8) LEIPZIG RAIL ^ (9) LEIPZIG HBF RAIL STN ^
		# (10) LEIPZIG RAIL ^ (11) LEIPZIG/HALLE/DE:LEIPZIG HBF R ^
		# (12) LEIPZIG/HALLE ^
		# (13) LEJ ^ (14) Y ^ (15)  ^ (16) DE ^ (17) EUROP ^ (18) ITC2 ^
		# (19) DE040 ^ (20) 51.3 ^ (21) 12.3333 ^ (22)  ^ (23) N

	} else if (NF >= 30) {
		####
		## Not in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $2 "^" $7 "^Y^" $8 "^" $9 "^" $10)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $29 "^" $3 "^" $4 "^" $15 "^" $16)

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $13 "^" $14)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $17 "^" $18 "^" $19 "^" $20)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $21 "^" $22 "^" $23)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $24 "^" $25 "^" $26 "^" $27)

		# ^ Modification date
		printf ("%s", "^" $28)

		# Location type
		location_type = substr ($1, 5)
		is_airport = match (location_type, "[A]")

		# ^ Is airport ^ Is commercial
		if (is_airport != 0) {
			printf ("%s", "^Y^Z")
		} else {
			printf ("%s", "^N^Z")
		}

		# ^ City code ^ State code
		printf ("%s", "^" $2 "^" $17)

		# ^ Region code
		region_full = $24
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
		printf ("%s", "^" location_type)

		# ^ Wiki link (potentially empty)
		printf ("%s", "^" $30)

		# Print the extra alternate names
		if (NF >= 31) {
			for (fld = 31; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $5)
		# (1) SQX-CA ^ (2) SQX ^ (3) -26.7816 ^ (4) -53.5035 ^ (5) SQX ^

		# From Geonames ($6 - $30+)
		# (6) SQX ^ (7) SSOE ^ (8) 7731508 ^ (9) São Miguel do Oeste Airport ^
		# (10) Sao Miguel do Oeste Airport ^ (11) -26.7816 ^ (12) -53.5035 ^
		# (13) BR ^ (14)  ^ (15) S ^ (16) AIRP ^
		# (17) 26 ^ (18)  ^ (19)  ^ (20)  ^
		# (21) 0 ^ (22) 0 ^ (23) 655 ^ (24) America/Sao_Paulo ^
		# (25) -2.0 ^ (26) -3.0 ^ (27) -3.0 ^ (28) 2011-03-18 ^ (29) SQX,SSOE ^
		# (30) 
		# [optional] ^ (31+)

	} else if (NF == 5) {
		####
		## Neither in Geonames nor in RFD
		####
		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Name ^ ASCII name
		printf ("%s", $1 "^ZZZZ^N^0^" "UNKNOWN" unknown_idx \
				"^" "UNKNOWN" unknown_idx) > non_ori_por_file

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4) > non_ori_por_file

		#  ^ Feat. class ^ Feat. code
		printf ("%s", "^S^AIRP") > non_ori_por_file

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" "ZZ" "^") > non_ori_por_file

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^^^^") > non_ori_por_file

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^") > non_ori_por_file

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" "Europe/Greenwich" "^^^") > non_ori_por_file

		# ^ Modification date
		printf ("%s", "^" today_date) > non_ori_por_file

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" "Y" "^" "Y") > non_ori_por_file

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" "ZZZ" "^" "^" "UNKOWN") > non_ori_por_file

		#  ^ Location type ^ Wiki link (empty here)
		printf ("%s", "^" "CA" "^" "\n") > non_ori_por_file

		# ----
		# From ORI-POR ($1 - $5)
		# (1) SFY-C ^ (2) SFY ^ (3) 42.17 ^ (4) -72.6 ^ (5) SFY

		#
		unknown_idx++

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) \
			> "/dev/stderr"
	}

}
