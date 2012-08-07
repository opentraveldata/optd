##
#
# Sample lines for allCountries.txt:
# geonameid	name	asciiname	alternatenames	latitude	longitude	fclass	fcode	country	cc2	admin1	admin2	admin3	admin4	population	elevation	gtopo30	timezone	moddate
# 6299418	Nice Côte d'Azur International Airport	Nice Cote d'Azur International Airport	Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto	43.66272	7.20787	S	AIRP	FR		B8	06	062	06088	0	3	-9999	Europe/Paris	2012-06-30
#
# Samples lines for alternateNames.txt
# alternatenameid	geonameid	isoLanguage	alternateName	isPreferredName	isShortName	isColloquial	isHistoric
# 1886047	6299418	icao	LFMN				
# 1888981	6299418	iata	NCE				
# 1969714	6299418	de	Flughafen Nizza				
# 1969715	6299418	en	Nice Côte d'Azur International Airport				
# 2187822	6299418	es	Niza Aeropuerto	1	1		
# 3032536	6299418	link	http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport				
# 5713800	6299418	fr	Aéroport de Nice Côte d'Azur				
# 7717894	6299418	en	Nice Airport		1	

##
#
BEGIN {
	por_line = 0
	alt_line = 0
}

##
# alternateNames.txt
#
# First, for every Geoname ID, concatenate all the alternate name details
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
# Simply add the string of alternate name details to the corresponding line
# of details for a given Geoname ID.
#
/^([0-9]{1,9})\t.*\t([0-9]{4}-[0-9]{2}-[0-9]{2})$/ {
	por_line++

	# Geoname ID
	geoname_id = $1

	# Retrieve the details coming from the alternate names
	iata_code = alt_name_list_iata[geoname_id]
	icao_code = alt_name_list_icao[geoname_id]
	faac_code = alt_name_list_faac[geoname_id]
	link_code = alt_name_list_link[geoname_id]
	link2_code = alt_name_list_link2[geoname_id]
	alt_names = alt_name_list_lang[geoname_id]

	# Concatenate the details
	conc_details = iata_code "^" icao_code "^" faac_code "^" link_code "^" alt_names

	# Cleaning
	delete alt_name_list_iata[geoname_id]
	delete alt_name_list_icao[geoname_id]
	delete alt_name_list_faac[geoname_id]
	delete alt_name_list_link[geoname_id]
	delete alt_name_list_link2[geoname_id]
	delete alt_name_list_lang[geoname_id]

	# Add those details to the line, and let AWK rewrite the whole line with
	# the new separator ("^")
	OFS = "^"
	$(NF+1) = conc_details
	print ($0)

	# Notification when multiple English Wikipedia links for a single POR
	if (link2_code != "" && iata_code != "" && log_level >= 5) {
		printf ("%s", "!!!! [" FNR "] There are duplicated English Wikipedia links, i.e., at least " link2_code " and " link_code ". The Geoname ID is " geoname_id "\n") > "/dev/stderr"
	}
}

##
#
END {
	# DEBUG
	#print ("Nb of POR: " por_line ", nb of alternate names: " alt_line)
}
