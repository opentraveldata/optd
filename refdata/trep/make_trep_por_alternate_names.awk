##
#
# Header
BEGIN {
	printf ("language_code^iata_code^ascii_name^utf_name")
	printf ("^lang_alt1^alt_name1^lang_alt2^alt_name2^lang_alt3^alt_name3")
	printf ("^lang_alt4^alt_name4^lang_alt5^alt_name5^lang_alt6^alt_name6")
	printf ("^lang_alt7^alt_name7^lang_alt8^alt_name8")
	printf ("^lang_alt9^alt_name9^lang_alt10^alt_name10")
	printf ("\n")
}

## M A I N
{
	# Initialisation
	delete alt_name_list

	# Transform the IATA code into lower case characters
	iata_code = tolower ($1)

	# Extract the ASCII version of the English name.
	place_name = tolower ($6)
	alt_name_list["en"] = place_name

	# Extract the UTF8 version of the English name.
	# When the UTF8 version differs from the ASCII one, add the former as an
	# alternate name. Otherwise, the UTF8 version is kept empty (no need to duplicate).
	if ($5 != $6) {
		alt_name = tolower ($5)
	} else {
		alt_name = ""
	}
	alt_name_list["en"] = sprintf ("%s", alt_name_list["en"] "^" alt_name)

	# Browse all the alternate names
	if (NF >= 33) {

		# The alternate names are indeed (ISO language code, alternate name) pairs
		for (fld = 33; fld <= NF; fld++) {

			# Extract the ISO language code
			alt_iso = tolower ($fld); fld++

			# If null, the language code is considered to be English
			if (alt_iso == "") {
				alt_iso = "en"
			}

			# Extract the alternate name itself
			alt_name = tolower ($fld)

			# Add the alternate name to the list for that language code, only when not
			# already registered (duplicates may happen on Geonames)
			if (match (alt_name_list[alt_iso], alt_name) == 0) {

				if (alt_name_list[alt_iso] == "") {
					# First alternate name for that language code.
					# Note that two empty fields must be inserted at the beginning
					# of the line, equal respectively to ASCII name and UTF names.
					alt_name_list[alt_iso] = sprintf ("%s", "^^" alt_name)

				} else {
					# Alternate name for that language code
					alt_name_list[alt_iso] = sprintf ("%s", alt_name_list[alt_iso] "^" alt_name)
				}
			}
		}
	}

	# Browse all the language codes
	for (iso_idx in alt_name_list) {
		printf ("%s", iso_idx "^" iata_code "^" alt_name_list[iso_idx] "\n")
	}
}
