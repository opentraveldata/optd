####
##
##
##
# 1. Sample lines for:
# 1.1. allCountries.txt
# ---------------------
# geonameid	name asciiname alternatenames latitude longitude fclass fcode country cc2 admin1 admin2 admin3 admin4 population elevation gtopo30 timezone moddate
# 6299418	Nice Côte d'Azur International Airport	Nice Cote d'Azur International Airport	Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto	43.66272	7.20787	S	AIRP	FR		B8	06	062	06088	0	3	-9999	Europe/Paris	2012-06-30
# 2990440 Nice Nice NCE,Nica,Nicaea,Nicca,Nice,Nicea,Nico,Nisa,Niza,Nizza,Niça,ni si,nisa,nisu,nitsa,nys,Ница,Ницца,ניס,نيس,नीस,ნიცა,ニース,尼斯 43.70313 7.26608 P PPLA2 FR  B8 06 062 06088 338620 25 18 Europe/Paris 2011-11-02
#
# 1.2. alternateNames.txt
# -----------------------
# alternatenameid geonameid isoLanguage alternateName isPreferredName isShortName isColloquial isHistoric
# 1886047	6299418	icao	LFMN				
# 1888981	6299418	iata	NCE				
# 1969714	6299418	de	Flughafen Nizza				
# 1969715	6299418	en	Nice Côte d'Azur International Airport				
# 2187822	6299418	es	Niza Aeropuerto	1	1		
# 3032536	6299418	link	http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport				
# 5713800	6299418	fr	Aéroport de Nice Côte d'Azur				
# 7717894	6299418	en	Nice Airport		1	
# 1628019	2990440	en	Nice
# 1628030	2990440	fr	Nice
# 1628021	2990440	es	Niza	1	1		
# 1628023	2990440	ar	نيس				
# 1628031	2990440	he	ניס				
# 1628034	2990440	ja	ニース
# 1628046	2990440	ru	Ницца
# 1633915	2990440	zh	尼斯
# 2964254	2990440	link	http://en.wikipedia.org/wiki/Nice				
# 3054759	2990440	link	http://ru.wikipedia.org/wiki/%D0%9D%D0%B8%D1%86%D1%86%D0%B0
#
# 1.3. timeZones.txt
# ------------------
# CountryCode TimeZoneId GMT offset 1. Jan 2012 DST offset 1. Jul 2012 rawOffset (independant of DST)
# US America/Anchorage -9.0 -8.0 -9.0
# US America/Los_Angeles -8.0 -7.0 -8.0
# US America/Indiana/Indianapolis -5.0 -4.0 -5.0
# US America/New_York -5.0 -4.0 -5.0
# GB Europe/London 0.0 1.0 0.0
# FR Europe/Paris 1.0 2.0 1.0
# RU Europe/Volgograd 4.0 4.0 4.0
# CN Asia/Shanghai 8.0 8.0 8.0
# AU Australia/Sydney 11.0 10.0 10.0
# RU Asia/Vladivostok 11.0 11.0 11.0
#
# 2. Sample lines for output:
# ---------------------------
# iata_code^icao_code^geonameid^name^asciiname^latitude^longitude^country^cc2^fclass^fcode^admin1^admin2^admin3^admin4^population^elevation^gtopo30^timezone^GMT_offset^DST_offset^raw_offset^moddate^alternatenames^wiki_link^altname_iso^altname_text
# NCE^LFMN^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.6627200^7.2078700^FR^^S^AIRP^B8^06^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en^Nice Airport^en^Nice Côte d'Azur International Airport
# NCE^NULL^2990440^Nice^Nice^43.7031300^7.2660800^FR^^P^PPLA2^B8^06^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2011-11-02^NCE,Nica,Nicaea,Nicca,Nice,Nicea,Nico,Nisa,Niza,Nizza,Niça,ni si,nisa,nisu,nitsa,nys,Ница,Ницца,ניס,نيس,नीस,ნიცა,ニース,尼斯^http://en.wikipedia.org/wiki/Nice


##
#
BEGIN {
	tz_line = 0
	por_line = 0
	alt_line = 0
}

##
# timeZones.txt
#
# Register all the time-zones
#
/^([A-Z]{2})\t.*\t([0-9.-]*)\t([0-9.-]*)\t([0-9.-]*)$/ {
	#
	tz_line++

	# Country code
	ctry_code = $1

	# Time-zone ID
	tz_id = $2

	# GMT offset
	gmt_offset = $3

	# DST offset
	dst_offset = $4

	# Raw offset
	raw_offset = $5

	# Register the time-zone details
	tz_list_ctry[tz_id] = ctry_code
	tz_list_gmt[tz_id] = gmt_offset
	tz_list_dst[tz_id] = dst_offset
	tz_list_raw[tz_id] = raw_offset
}

##
# alternateNames.txt
#
# For every Geoname ID, concatenate all the alternate name details
# into a single string/line.
#
/^([0-9]{1,9})\t([0-9]{1,9})\t([a-z]{0,5}[_]{0,1}[0-9]{0,4})\t/ {
	#alt_line++

	# Alternate name ID
	alt_name_id = $1

	# Geoname ID
	geoname_id = $2

	# Alternate name type (IATA, ICAO, FAA, Wikipedia link, language code)
	alt_name_type = $3

	# Alternate name
	alt_name_content = $4

	# Whether that alternate name is historical
	is_historical = $8
	if (is_historical == "1") {
		is_historical = "h"
	}

	#
	if (alt_name_type == "iata") {
		if (is_historical != "h") {
			alt_name_list_iata[geoname_id] = alt_name_content
		} else {
			alt_name_list_iata[geoname_id] = "_" alt_name_content
		}

	} else if (alt_name_type == "icao") {
		if (is_historical != "h") {
			alt_name_list_icao[geoname_id] = alt_name_content
		} else {
			alt_name_list_icao[geoname_id] = "_" alt_name_content
		}

	} else if (alt_name_type == "faac") {
		if (is_historical != "h") {
			alt_name_list_faac[geoname_id] = alt_name_content
		} else {
			alt_name_list_faac[geoname_id] = "_" alt_name_content
		}

	} else if (alt_name_type == "link") {
		# Check that the Wikipedia link is for English
		is_en_wiki_link = match (alt_name_content, "http://en.")

		# The Wikipedia link may have already been set (there are sometimes
		# multiple distinct English Wikipedia links)
		alt_name_link = alt_name_list_link[geoname_id]

		if (is_en_wiki_link != 0 && is_historical != "h") {
			# Register the link
			alt_name_list_link[geoname_id] = alt_name_content

			# Handle any override of the Wikipedia link. If any, the
			# notification will be issued later, when the type of the POR
			# will be known for sure (as we want to notify only for IATA
			# known POR).
			if (alt_name_link != "") {
				alt_name_list_link2[geoname_id] = alt_name_link
			}
		}

	} else {
		# Check whether the type is language-related
		is_lang_related = match (alt_name_type, "[a-z]{0,5}[_]{0,1}[0-9]{0,4}")
		if (alt_name_type == "") {
			is_lang_related = 1
		}

		# When it is language related
		if (is_lang_related == 1) {
			# Whether that alternate name is the preferred one in that language
			is_preferred = $5
			if (is_preferred == "1") {
				is_preferred = "p"
			}

			# Whether that alternate name is the short version in that language
			is_short = $6
			if (is_short == "1") {
				is_short = "s"
			}

			# Whether that alternate name is colloquial in that language
			is_colloquial = $7
			if (is_colloquial == "1") {
				is_colloquial = "c"
			}

			# Retrieve the concatenated string of the language-related
			# alternate names for that Geoname ID, if any.
			alt_name_lang_full = alt_name_list_lang[geoname_id]
			if (alt_name_lang_full != "") {
				alt_name_lang_full = alt_name_lang_full "^"
			}

			# Concatenate the new alternate name, and (re-)register it.
			alt_name_list_lang[geoname_id] = alt_name_lang_full alt_name_type "^" alt_name_content "^" is_preferred is_short is_colloquial is_historical

		} else {
			# Notification
			if (log_level >= 5) {
				printf ("%s", "!!!! [" FNR "] The type of the alternate name ('" alt_name_type "') is unknown. The Geoname ID is " geoname_id "\n") > "/dev/stderr"
			}
		}
	}
}

##
# allCountries.txt
#
# Parse the POR details, and output them in the desired format.
# The time-zone and alternate name details, corresponding to the every current line
# (for a given Geoname ID), are also integrated.
#
/^([0-9]{1,9})\t.*\t([0-9]{4}-[0-9]{2}-[0-9]{2})$/ {
	por_line++

	# Geoname ID
	geoname_id = $1

	# Name (may be in UTF8)
	utf8_name = $2

	# ASCII Name
	ascii_name = $3

	# Compact version (without language codes) of the list of alternate names
	alt_names_compact = $4

	# Geographical coordinates (latitude, longitude)
	latitude = $5
	longitude = $6

	# POR type
	fclass = $7
	fcode = $8

	# Country codes
	ctry_code = $9
	cc_code_list = $10

	# Admin codes
	adm_code1 = $11
	adm_code2 = $12
	adm_code3 = $13
	adm_code4 = $14

	# Population
	population = $15

	# Topology
	elevation = $16
	gtopo30 = $17

	# Time-zone
	tz_id = $18

	# Modification date
	mod_date = $19

	# Retrieve the details coming from the time zone
	tz_ctry = tz_list_ctry[tz_id]
	gmt_offset = tz_list_gmt[tz_id]
	dst_offset = tz_list_dst[tz_id]
	raw_offset = tz_list_raw[tz_id]

	# Cleaning
	delete tz_list_ctry[tz_id]
	delete tz_list_gmt[tz_id]
	delete tz_list_dst[tz_id]
	delete tz_list_raw[tz_id]

	# Retrieve the details coming from the alternate names
	iata_code = alt_name_list_iata[geoname_id]
	icao_code = alt_name_list_icao[geoname_id]
	faac_code = alt_name_list_faac[geoname_id]
	link_code = alt_name_list_link[geoname_id]
	link2_code = alt_name_list_link2[geoname_id]
	alt_names = alt_name_list_lang[geoname_id]

	# Cleaning
	delete alt_name_list_iata[geoname_id]
	delete alt_name_list_icao[geoname_id]
	delete alt_name_list_faac[geoname_id]
	delete alt_name_list_link[geoname_id]
	delete alt_name_list_link2[geoname_id]
	delete alt_name_list_lang[geoname_id]

	# Build the output line, in the desired format
	out_line = iata_code "^" icao_code "^" geoname_id "^" utf8_name "^" ascii_name
	out_line = out_line "^" latitude "^" longitude "^" ctry_code "^" cc_code_list 
	out_line = out_line "^" fclass "^" fcode
	out_line = out_line "^" adm_code1 "^" adm_code2 "^" adm_code3 "^" adm_code4
	out_line = out_line "^" population "^" elevation "^" gtopo30
	out_line = out_line "^" tz_id "^" gmt_offset "^" dst_offset "^" raw_offset "^" moddate
	out_line = out_line "^" alt_names_compact
	out_line = out_line "^" link_code "^" alt_names

	# Print the output line
	print (out_line)

	# Notification when multiple English Wikipedia links for a single POR
	if (link2_code != "" && iata_code != "" && log_level >= 5) {
		printf ("%s", "!!!! [" FNR "] There are duplicated English Wikipedia links, i.e., at least " link2_code " and " link_code ". The Geoname ID is " geoname_id "\n") > "/dev/stderr"
	}
}

##
#
END {
	# DEBUG
	print ("Nb of TZ: " tz_line ", nb of POR: " por_line ", nb of alternate names: " alt_line)
}
