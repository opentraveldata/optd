##
# That AWK script re-formats the full details of POR (points of reference)
# derived from four sources:
#  * Amadeus ORI-maintained list of best known coordinates
#  * Amadeus ORI-maintained list of PageRank values
#  * Amadeus RFD (Referential Data)
#  * Geonames
#
# Sample output lines:
# IEV^UKKK^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^Kyiv Airport,...^50.401694^30.449697^S^AIRP^0.0118932671093^^^^UA^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Y^Y^IEV^^EURAS^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en^Kyiv Airport^s
# IEV^ZZZZ^Y^703448^^Kiev^Kiev^Kiiev,...^50.401694^30.449697^P^PPLC^0.10607170217^^^^UA^^12^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-08-18^N^N^IEV^^EURAS^C^http://en.wikipedia.org/wiki/Kiev^et^Kiiev^
# NCE^LFMN^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^Nice Airport,...^43.658411^7.215872^S^AIRP^0.158985215433^^^^FR^^B8^06^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Y^Y^NCE^^EUROP^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en^Nice Airport^s
#

##
# Header
BEGIN {
	printf ("%s", "iata_code^icao_code^is_geonames^geoname_id^valid_id")
	printf ("%s", "^name^asciiname^alternatenames^latitude^longitude")
	printf ("%s", "^fclass^fcode")
	printf ("%s", "^page_rank^date_from^date_until^comment")
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


##
# File of PageRank values
#
# Sample lines:
# LON-C^LON^1.0
# PAR-C^PAR^0.994632137197
# NYC-C^NYC^0.948221089373
# CHI-C^CHI^0.768305897463
# ATL-A^ATL^0.686723208248
# ATL-C^ATL^0.686723208248
# NCE-CA^NCE^0.158985215433
# ORD-A^ORD^0.677280625337
# CDG-A^CDG^0.647060165878
#
/^([A-Z0-9]{3})-([A-Z]{1,2})\^([A-Z]{3})\^([0-9.]{1,15})$/ {
	# Primary key (IATA code and location pseudo-code)
	pk = $1

	# IATA code
	iata_code = substr (pk, 1, 3)

	# Location pseudo-type ('C' means City, but 'A' means any related to travel,
	# e.g., airport, heliport, port, bus or train station)
	por_type = substr (pk, 5)

	# Sanity check
	if (iata_code != $2) {
		print ("!!! Error at recrod #" FNR ": the IATA code ('" iata_code \
			   "') should be equal to the field #2 ('" $2 \
			   "'), but is not. The whole line " $0) > "/dev/stderr"
	}

	# Check whether it is a city
	is_city = match (por_type, "C")

	# Check whether it is travel-related
	is_tvl = match (por_type, "A")

	# PageRank value
	pr_value = $3

	# Store the PageRank value for that POR
	if (is_city != 0) {
		city_list[iata_code] = pr_value
	}
	if (is_tvl != 0) {
		tvl_list[iata_code] = pr_value
	}
}


##
# States whether that location type corresponds to a travel-related POR
function isTravel(myLocationType) {
	is_airport = match (myLocationType, "A")
	is_rail = match (myLocationType, "R")
	is_bus = match (myLocationType, "B")
	is_heliport = match (myLocationType, "H")
	is_port = match (myLocationType, "P")
	is_ground = match (myLocationType, "G")
	is_offpoint = match (myLocationType, "O")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port	\
		+ is_ground + is_offpoint

	return is_travel
}

##
# Retrieve the PageRank value for that POR
function getPageRank(myIataCode, myLocationType) {
	is_city = match (myLocationType, "C")
	is_tvl = isTravel(myLocationType)
	
	if (is_city != 0) {
		page_rank = city_list[myIataCode]

	} else if (is_tvl != 0) {
		page_rank = tvl_list[myIataCode]

	} else {
		page_rank = ""
	}

	return page_rank
}


##
# Aggregated content from Amadeus ORI, Amadeus RFD and Geonames
#
# Sample input lines:
#
# # Both in Geonames and in RFD (56 fields)
# NCE-CA^NCE^43.658411^7.215872^NCE^^NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Nice Airport,...^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^NCE^CA^NICE^COTE D AZUR^NICE^NICE/FR:COTE D AZUR^NICE^NCE^Y^^FR^EUROP^ITC2^FR052^43.6653^7.215^^Y^en|Nice Airport|s
#
# # In RFD (24 fields)
# XIT-R^XIT^51.42^12.42^LEJ^^XIT^R^LEIPZIG RAIL^LEIPZIG HBF RAIL STN^LEIPZIG RAIL^LEIPZIG/HALLE/DE:LEIPZIG HBF R^LEIPZIG/HALLE^LEJ^Y^^DE^EUROP^ITC2^DE040^51.3^12.3333^^N
#
# # In Geonames (38 fields)
# SQX-CA^SQX^-26.7816^-53.5035^SQX^^SQX^SSOE^^7731508^São Miguel do Oeste Airport^Sao Miguel do Oeste Airport^-26.7816^-53.5035^BR^^Brazil^S^AIRP^26^Santa Catarina^Santa Catarina^4204905^Descanso^Descanso^^^0^^655^America/Sao_Paulo^-2.0^-3.0^-3.0^2012-08-03^SQX,SSOE^^
#
/^([A-Z0-9]{3})-([A-Z]{1,2})\^([A-Z]{3})\^([0-9.+-]{0,12})\^/ {

	# When the 32nd field is a IATA code, it means that the POR is in
	# both Geonames and RFD.
	#is_32nd_fld_iata = match ($32, "[A-Z]{3}")
	#is_32nd_fld_lang = match ($32, "[a-z0-9]{2,3}")

	if (NF == 56) {
		####
		## Both in Geonames and in RFD
		####

		# Location type (extracted from the primary key)
		location_type = substr($1, 5)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^" $8 "^Y^" $10 "^")
		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		# printf ("%s", iata_code "^" $8 "^" $9 "^Y^" $10 "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $11 "^" $12)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $36 "^" $3 "^" $4 "^" $18 "^" $19)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^")

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $15 "^" $16)
		# ^ Country code ^ Alt. country codes ^ Country name
		# printf ("%s", "^" $15 "^" $16 "^" $17)

		# ^ Admin1 code ^ Admin2 code ^ Admin3 code ^ Admin4 code
		printf ("%s", "^" $20 "^" $23 "^" $26 "^" $27)
		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		# printf ("%s", "^" $20 "^" $21 "^" $22)
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		# printf ("%s", "^" $23 "^" $24 "^" $25)
		# ^ Admin3 code ^ Admin4 code
		# printf ("%s", "^" $26 "^" $27)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $28 "^" $29 "^" $30)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $31 "^" $32 "^" $33 "^" $34)

		# ^ Modification date
		printf ("%s", "^" $35)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $46 "^" $55)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $45 "^" $47 "^" $49)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" location_type "^" $37)

		##
		# ^ Section of alternate names
		altname_section = $56

		# Archive the full line and the separator
		full_line = $0
		fs_org = FS

		# Change the separator in order to parse the section of alternate names
		FS = "|"
		$0 = altname_section

		# Print the alternate names
		for (fld = 1; fld <= NF; fld++) {
			printf ("^%s", $fld)
		}

		# Restore the initial separator (and full line, if needed)
		FS = fs_org
		#$0 = full_line

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) NCE-CA ^ (2) NCE ^ (3) 43.658411 ^ (4) 7.215872 ^
		# (5) NCE ^ (6)  ^

		# From Geonames ($7 - $37)
		# (7) NCE ^ (8) LFMN ^ (9)  ^ (10) 6299418 ^
		# (11) Nice Côte d'Azur International Airport ^
		# (12) Nice Cote d'Azur International Airport ^
		# (13) 43.66272 ^ (14) 7.20787 ^
		# (15) FR ^ (16)  ^ (17) France ^ (18) S ^ (19) AIRP ^
		# (20) B8 ^ (21) Provence-Alpes-Côte d'Azur ^
		# (22) Provence-Alpes-Cote d'Azur ^
		# (23) 06 ^ (24) Département des Alpes-Maritimes ^ 
		# (25) Departement des Alpes-Maritimes ^
		# (26) 062 ^ (27) 06088 ^
		# (28) 0 ^ (29) 3 ^ (30) -9999
		# (31) Europe/Paris ^ (32) 1.0 ^ (33) 2.0 ^ (34) 1.0 ^
		# (35) 2012-06-30 ^
		# (36) Aeroport de Nice Cote d'Azur, ...,Niza Aeropuerto ^
		# (37) http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport ^

		# From RFD ($38 - $49)
		# (38) NCE ^ (39) CA ^ (40) NICE ^ (41) COTE D AZUR ^ (42) NICE ^
		# (43) NICE/FR:COTE D AZUR ^ (44) NICE ^ (45) NCE ^
		# (46) Y ^ (47)  ^ (48) FR ^ (49) EUROP ^ (50) ITC2 ^ (51) FR052 ^
		# (52) 43.6653 ^ (53) 7.215 ^ (54)  ^ (55) Y ^

		# From Geonames alternate names ($56)
		# (56) en | Nice Airport | s |
		#      en | Nice Côte d'Azur International Airport | 

	} else if (NF == 24) {
		####
		## Not in Geonames
		####

		# Location type (extracted from the primary key)
		location_type = substr($1, 5)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^ZZZZ^N^0^")
		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		# printf ("%s", iata_code "^ZZZZ^^N^0^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $12 "^" $12)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4)

		# ^ Feat. class ^ Feat. code
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

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^")

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $17 "^")
		# ^ Country code ^ Alt. country codes ^ Country name
		# printf ("%s", "^" $17 "^" $17)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^^^^")
		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		# printf ("%s", "^^^")
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		# printf ("%s", "^^^")
		# ^ Admin3 code ^ Admin4 code
		# printf ("%s", "^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $20 "^^^")

		# ^ Modification date
		printf ("%s", "^" today_date)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $15 "^" $24)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $14 "^" $16 "^" $18)

		# ^ Location type
		printf ("%s", "^" location_type)

		# ^ Wiki link (empty here)
		printf ("%s", "^")

		# ^ Section of alternate names (empty here)
		# printf ("%s", "^")

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) XIT-R ^ (2) XIT (3) 51.42 ^ (4) 12.42 ^
		# (5) LEJ ^ (6)  ^

		# From RFD ($7 - $24)
		# (7) XIT ^ (8) R ^ (9) LEIPZIG RAIL ^ (10) LEIPZIG HBF RAIL STN ^
		# (11) LEIPZIG RAIL ^ (12) LEIPZIG/HALLE/DE:LEIPZIG HBF R ^
		# (13) LEIPZIG/HALLE ^
		# (14) LEJ ^ (15) Y ^ (16)  ^ (17) DE ^ (18) EUROP ^ (19) ITC2 ^
		# (20) DE040 ^ (21) 51.3 ^ (22) 12.3333 ^ (23)  ^ (24) N

	} else if (NF == 38) {
		####
		## Not in RFD
		####

		# Location type (extracted from the primary key)
		location_type = substr($1, 5)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^" $8 "^Y^" $10 "^")
		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		# printf ("%s", iata_code "^" $8 "^" $9 "^Y^" $10 "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $11 "^" $12)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $36 "^" $3 "^" $4 "^" $18 "^" $19)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^")

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $15 "^" $16)
		# ^ Country code ^ Alt. country codes ^ Country name
		# printf ("%s", "^" $15 "^" $16 "^" $17)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $20 "^" $23 "^" $26 "^" $27)
		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		# printf ("%s", "^" $20 "^" $21 "^" $22)
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		# printf ("%s", "^" $23 "^" $24 "^" $25)
		# ^ Admin3 code ^ Admin4 code
		# printf ("%s", "^" $26 "^" $27)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $28 "^" $29 "^" $30)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $31 "^" $32 "^" $33 "^" $34)

		# ^ Modification date
		printf ("%s", "^" $35)

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
		printf ("%s", "^" $2 "^" $20)

		# ^ Region code
		region_full = $31
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
		printf ("%s", "^" $37)

		##
		# ^ Section of alternate names
		altname_section = $38

		# Archive the full line and the separator
		full_line = $0
		fs_org = FS

		# Change the separator in order to parse the section of alternate names
		FS = "|"
		$0 = altname_section

		# Print the alternate names
		for (fld = 1; fld <= NF; fld++) {
			printf ("^%s", $fld)
		}

		# Restore the initial separator (and full line, if needed)
		FS = fs_org
		#$0 = full_line

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) SQX-CA ^ (2) SQX ^ (3) -26.7816 ^ (4) -53.5035 ^ 
		# (5) SQX ^ (6)  ^

		# From Geonames ($7 - $38)
		# (7) SQX ^ (8) SSOE ^ (9)  ^ (10) 7731508 ^
		# (11) São Miguel do Oeste Airport ^
		# (12) Sao Miguel do Oeste Airport ^ (13) -26.7816 ^ (14) -53.5035 ^
		# (15) BR ^ (16)  ^ (17) Brazil ^ (18) S ^ (19) AIRP ^
		# (20) 26 ^ (21) Santa Catarina ^ (22) Santa Catarina ^
		# (23) 4204905 ^ (24) Descanso ^ (25) Descanso ^ (26)  ^ (27)  ^
		# (28) 0 ^ (29)  ^ (30) 655 ^ (31) America/Sao_Paulo ^
		# (32) -2.0 ^ (33) -3.0 ^ (34) -3.0 ^ (35) 2011-03-18 ^ (36) SQX,SSOE ^
		# (37)  ^ (38)  

	} else if (NF == 6) {
		####
		## Neither in Geonames nor in RFD
		####
		# Location type (extracted from the primary key)
		location_type = "A"

		# IATA code
		iata_code = $1

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		#
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^ZZZZ^N^0^") > non_ori_por_file
		# IATA code ^ ICAO code ^ Is in Geonames ^ GeonameID ^ Validity ID
		# printf ("%s", iata_code "^ZZZZ^^N^0^") > non_ori_por_file

		# ^ Name ^ ASCII name
		printf ("%s", "^UNKNOWN" unknown_idx "^UNKNOWN" unknown_idx) \
			> non_ori_por_file

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4) > non_ori_por_file

		#  ^ Feat. class ^ Feat. code
		printf ("%s", "^S^AIRP") > non_ori_por_file

		# ^ PageRank value
		printf ("%s", "^" page_rank) > non_ori_por_file

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^") > non_ori_por_file

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" "ZZ" "^") > non_ori_por_file
		# ^ Country code ^ Alt. country codes ^ Country name
		# printf ("%s", "^" "ZZ" "^" "Zzzzz") > non_ori_por_file

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^^^^") > non_ori_por_file
		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		# printf ("%s", "^^^") > non_ori_por_file
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		# printf ("%s", "^^^") > non_ori_por_file
		# ^ Admin3 code ^ Admin4 code
		# printf ("%s", "^^") > non_ori_por_file

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

		#  ^ Location type (city and airport)
		printf ("%s", "^CA") > non_ori_por_file

		#  ^ Wiki link (empty here)
		printf ("%s", "^") > non_ori_por_file

		#  ^ Section of alternate names  (empty here)
		# printf ("%s", "^") > non_ori_por_file

		# End of line
		printf ("%s", "\n") > non_ori_por_file

		# ----
		# From ORI-POR ($1 - $6)
		# (1) SZD-C ^ (2) SZD ^ (3) 53.394256 ^ (4) -1.388486 ^ (5) SZD ^ (6)  

		#
		unknown_idx++

	} else {
		print ("!!!! Error for row #" FNR ", having " NF " fields: " $0) \
			> "/dev/stderr"
	}

}
