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
# Sample lines:
# # Both in Geonames and in RFD
# NCE-CA^NCE^43.658411^7.215872^NCE^^NCE^LFMN^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^S^AIRP^B8^06^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^NCE^CA^NICE^COTE D AZUR^NICE^NICE/FR:COTE D AZUR^NICE^NCE^Y^^FR^EUROP^ITC2^FR052^43.6653^7.215^^Y^de^Flughafen Nizza^^en^Nice Côte d'Azur International Airport^^es^Niza Aeropuerto^ps^fr^Aéroport de Nice Côte d'Azur^^en^Nice Airport^s
# # In RFD
# XIT-R^XIT^51.42^12.42^LEJ^^XIT^R^LEIPZIG RAIL^LEIPZIG HBF RAIL STN^LEIPZIG RAIL^LEIPZIG/HALLE/DE:LEIPZIG HBF R^LEIPZIG/HALLE^LEJ^Y^^DE^EUROP^ITC2^DE040^51.3^12.3333^^N
# # In Geonames
# SQX-CA^SQX^-26.7816^-53.5035^SQX^^SQX^SSOE^7731508^São Miguel do Oeste Airport^Sao Miguel do Oeste Airport^-26.7816^-53.5035^BR^^S^AIRP^26^4204905^^^0^^655^America/Sao_Paulo^-2.0^-3.0^-3.0^2012-08-03^SQX,SSOE^
#
/^([A-Z0-9]{3})-([A-Z]{1,2})\^([A-Z]{3})\^([0-9.+-]{0,12})\^/ {

	# When the 32nd field is a IATA code, it means that the POR is in
	# both Geonames and RFD.
	is_32nd_fld_iata = match ($32, "[A-Z]{3}")
	is_32nd_fld_lang = match ($32, "[a-z0-9]{2,3}")

	if (NF >= 49 && is_32nd_fld_iata == 1) {
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
		printf ("%s", iata_code "^" $8 "^Y^" $9 "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $10 "^" $11)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $30 "^" $3 "^" $4 "^" $16 "^" $17)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^")

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $14 "^" $15)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $18 "^" $19 "^" $20 "^" $21)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $22 "^" $23 "^" $24)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $25 "^" $26 "^" $27 "^" $28)

		# ^ Modification date
		printf ("%s", "^" $29)

		# ^ Is airport ^ Is commercial
		printf ("%s", "^" $40 "^" $49)

		# ^ City code ^ State code ^ Region code
		printf ("%s", "^" $39 "^" $41 "^" $43)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" location_type "^" $31)

		# Print the extra alternate names
		if (NF >= 50) {
			for (fld = 50; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) NCE-CA ^ (2) NCE ^ (3) 43.658411 ^ (4) 7.215872 ^
		# (5) NCE ^ (6)  ^

		# From Geonames ($7 - $31)
		# (7) NCE ^ (8) LFMN ^ (9) 6299418 ^
		# (10) Nice Côte d'Azur International Airport ^
		# (11) Nice Cote d'Azur International Airport ^
		# (12) 43.66272 ^ (13) 7.20787 ^
		# (14) FR ^ (15)  ^ (16) S ^ (17) AIRP ^
		# (18) B8 ^ (19) 06 ^ (20) 062 ^ (21) 06088 ^
		# (22) 0 ^ (23) 3 ^ (24) -9999
		# (25) Europe/Paris ^ (26) 1.0 ^ (27) 2.0 ^ (28) 1.0 ^
		# (29) 2012-06-30 ^
		# (30) Aeroport de Nice Cote d'Azur, ...,Niza Aeropuerto ^
		# (31) http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport ^

		# From RFD ($32 - $49)
		# (32) NCE ^ (33) CA ^ (34) NICE ^ (35) COTE D AZUR ^ (36) NICE ^
		# (37) NICE/FR:COTE D AZUR ^ (38) NICE ^ (39) NCE ^
		# (40) Y ^ (41)  ^ (42) FR ^ (43) EUROP ^ (44) ITC2 ^ (45) FR052 ^
		# (46) 43.6653 ^ (47) 7.215 ^ (48)  ^ (49) Y

		# [optional] From Geonames alternate names ($50+)
		# (50) ^ en (51) ^ Nice Airport ^ (52) 
		# (53) ^ en (54) ^ Nice Côte d'Azur International Airport ^ (55) 

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

		# ^ Name ^ ASCII name
		printf ("%s", "^" $12 "^" $12)

		# ^ Alternate names ^ Latitude ^ Longitude
		printf ("%s", "^^" $3 "^" $4)

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

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^")

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $17 "^")

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^^^^")

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

		# ^ Location type ^ Wiki link (empty here)
		printf ("%s", "^" location_type "^")

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

	} else if (NF >= 31) {
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
		printf ("%s", iata_code "^" $8 "^Y^" $9 "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $10 "^" $11)

		# ^ Alternate names ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $30 "^" $3 "^" $4 "^" $16 "^" $17)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^")

		# ^ Country code ^ Alt. country codes
		printf ("%s", "^" $14 "^" $15)

		# ^ Admin1 ^ Admin2 ^ Admin3 ^ Admin4
		printf ("%s", "^" $18 "^" $19 "^" $20 "^" $21)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $22 "^" $23 "^" $24)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $25 "^" $26 "^" $27 "^" $28)

		# ^ Modification date
		printf ("%s", "^" $29)

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
		printf ("%s", "^" $2 "^" $18)

		# ^ Region code
		region_full = $25
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
		printf ("%s", "^" $31)

		# Print the extra alternate names
		if (NF >= 32) {
			for (fld = 32; fld <= NF; fld++) {
				printf ("^%s", $fld)
			}
		}

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) SQX-CA ^ (2) SQX ^ (3) -26.7816 ^ (4) -53.5035 ^ 
		# (5) SQX ^ (6)  ^

		# From Geonames ($7 - $31+)
		# (7) SQX ^ (8) SSOE ^ (9) 7731508 ^ (10) São Miguel do Oeste Airport ^
		# (11) Sao Miguel do Oeste Airport ^ (12) -26.7816 ^ (13) -53.5035 ^
		# (14) BR ^ (15)  ^ (16) S ^ (17) AIRP ^
		# (18) 26 ^ (19)  ^ (20)  ^ (21)  ^
		# (22) 0 ^ (23) 0 ^ (24) 655 ^ (25) America/Sao_Paulo ^
		# (26) -2.0 ^ (27) -3.0 ^ (28) -3.0 ^ (29) 2011-03-18 ^ (30) SQX,SSOE ^
		# (31) 
		# [optional] ^ (32+)

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
