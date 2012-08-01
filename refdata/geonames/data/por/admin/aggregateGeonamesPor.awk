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

	# Retrieve the concatenated string of alternate names for that Geoname ID,
	# if any.
	alt_name_full = alt_name_list[geoname_id]
	if (alt_name_full == "") {
		# No alternate name was already registered. Trunk the current alternate
		# details. In practice, only the Geoname ID will be removed (and the
		# alternate name ID will be re-added).
		alt_name_id_length = length (alt_name_id)
		truncated_alt_name = substr ($0, alt_name_id_length + 2)

		# Let AWK reprocess the whole line, using ^ as a separator
		OFS = "^"
		$0 = truncated_alt_name

		# Substitute the Geoname ID (former #2 field, now #1) with the
		# alternate name ID
		$1 = alt_name_id

	} else {
		# (At least) An alternate name was already registered for that
		# Geoname ID.
		# The Geoname ID is replaced with the alternate name ID.
		$2 = alt_name_id

		# The field holding the alternate ID is replaced by the
		# concatenated string of all thoses previously registered
		# alternate names. AWK reprocesses the whole line, so as to replace
		# the separator by the ^ character. The remaining of the alternate
		# name details remained unchanged.
		OFS = "^"
		$1 = alt_name_full
	}

	# Register the full string for that Geoname ID
	alt_name_list[geoname_id] = $0
}

##
# allCountries.txt
#
# Simply add the string of alternate name details to the corresponding line
# of details for a given Geoname ID.
#
/^([0-9]{1,9})\t.*\t([0-9]{4}-[0-9]{2}-[0-9]{2})$/ {
	#por_line++

	# Geoname ID
	geoname_id = $1

	# Add the concatenated list of alternate name to the whole line
	OFS = "^"
	$(NF+1) = alt_name_list[geoname_id]
	print ($0)
}

##
#
END {
	# DEBUG
	#print ("Nb of POR: " por_line ", nb of alternate names: " alt_line)
}
