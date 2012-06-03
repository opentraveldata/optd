##
# Aggregate the language (e.g., 'en', 'ru', 'zh', 'link') alternate names
# on a single line.
# The alternate names of the same POR, specified as having the same IATA
# and ICAO codes, as well as the same Geonames ID.

#
function reset_alt_name() {
	delete last_alt_name_list
	for (alt_idx_tmp in alt_name_list) {
		last_alt_name_list[alt_idx_tmp] = alt_name_list[alt_idx_tmp]
	}
	delete alt_name_list
	last_alt_idx = alt_idx
	alt_idx = 0
}

#
function print_whole_line() {
	# Add the Wikipedia link. Even when not existing, the field is output,
	# so that MySQL does not take an alternate name with a Wikipedia link
	last_whole_line = last_whole_line "^" last_wiki_link

	# Add the list of alternate names to the POR details
	if (last_alt_idx != 0) {
		asort (last_alt_name_list)
		for (alt_name_idx in last_alt_name_list) {
			last_whole_line = last_whole_line "^" last_alt_name_list[alt_name_idx]
		}
	}

	#
	print (last_whole_line)
}

##
#
BEGIN {
	whole_line = ""
	alt_idx = 0
	iso_list["en"] = 1; iso_list["ru"] = 1; iso_list["zh"] = 1
}

##
# M A I N
{
	# Reset the last state of the variables, only when the POR changes
	if (last_iata_code != $1 || last_icao_code != $2 || last_geo_id != $3) {
		last_wiki_link = wiki_link
		wiki_link = ""
		reset_alt_name()
		last_whole_line = whole_line
	}

	# Remove any trailing "^NULL" field. Decrementing NF reduces $0 as well.
	OFS = FS
	if ($NF == "NULL") {
		NF--
	}
	if ($NF == "NULL") {
		NF--
	}

	#
	iso_language = $(NF-1)
	alt_name = $NF

	# DEBUG
	if (last_iata_code == $1 && last_icao_code == $2 && last_geo_id == $3) {
		is_change = "CONT"
	} else {
		is_change = "CHANGE"
	}
	#printf ("[DEBUG][" FNR "][" is_change "] $1=" $1 "/iata=" last_iata_code ", $2=" $2)
	#printf ("/icao=" last_icao_code ", $3=" $3 "/geo=" last_geo_id "\n")
	#printf ("[DEBUG][" FNR "][" is_change "] cur_iso=" iso_language ", cur_alt=" alt_name "\n")

	# Add the Wikipedia link
	if (iso_language == "link") {
		is_en_wiki_link = match (alt_name, "http://en.")
		if (is_en_wiki_link != 0) {
			wiki_link = alt_name
		}
		alt_name = "NULL"

		# Remove the link from the line (it will be added afterwards,
		# without the 'link' keyword)
		NF--; NF--
	}
		
	# DEBUG
	#printf ("[DEBUG][" FNR "][" is_change "] is_wiki=" is_en_wiki_link)
	#printf (", wiki=" wiki_link " -- last_wiki=" last_wiki_link "\n")

	# Add the alternate name to the dedicated list
	if (alt_name != "NULL" && (iso_language == "" || iso_language in iso_list)){
		alt_name_list[alt_idx] = iso_language "^" alt_name
		alt_idx++

		# Remove the alternate name from the line (it will be
		# added afterwards, together with the alternate names of
		# other languages, if any)
		NF--; NF--
	}

	#
	whole_line = $0
		
	# DEBUG
	#printf ("[DEBUG][" FNR "][" is_change "] whole_line=" whole_line "\n")
	#printf ("[DEBUG][" FNR "][" is_change "] last_whole_line=" last_whole_line "\n")

	# DEBUG
	#printf ("[DEBUG][" FNR "][" is_change "] alt_idx=" alt_idx)
	#printf ("/last_idx=" last_alt_idx ", ")
	for (alt_name_idx in alt_name_list) {
		#printf ("alt=" alt_name_list[alt_name_idx] ", ")
	}
	#printf (" -- ")
	for (alt_name_idx in last_alt_name_list) {
		#printf ("last_alt=" last_alt_name_list[alt_name_idx] ", ")
	}
	#printf ("\n")

	if (last_iata_code == $1 && last_icao_code == $2 && last_geo_id == $3) {
		# The current POR is the same as the previous one. So, add the
		# (ISO language, alternate name) to the list of alternate names
		# of that POR.

	} else {
		# The current POR is different from the previous one. It is therefore
		# time to print that line (POR details).
		if (last_whole_line != "") {
			print_whole_line()
		}
	}

	# Iteration
	last_iata_code = $1 ; last_icao_code = $2 ; last_geo_id = $3
}

##
#
END {
	last_wiki_link = wiki_link
	last_whole_line = whole_line
	reset_alt_name()
	print_whole_line()
}
