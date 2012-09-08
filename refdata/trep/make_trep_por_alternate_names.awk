##
#
# Header
BEGIN {
	printf ("language_code^pk^iata_code^ascii_name^utf_name")
	printf ("^lang_alt1^alt_name1^lang_alt2^alt_name2^lang_alt3^alt_name3")
	printf ("^lang_alt4^alt_name4^lang_alt5^alt_name5^lang_alt6^alt_name6")
	printf ("^lang_alt7^alt_name7^lang_alt8^alt_name8")
	printf ("^lang_alt9^alt_name9^lang_alt10^alt_name10")
	printf ("\n")
}

##
# M A I N
#
# ORI-maintained list of POR (points of reference)
#
# Sample (partial) lines:
# IEV-A^IEV^UKKK^Y^6300960^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^Aehroport «Kiev» (Zhuljany),IEV ...^50.401694^30.449697^S^AIRP^UA^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Y^Y^IEV^^EURAS^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en^Kyiv Zhuliany International Airport^^en^Kyiv International Airport^^en^Kyiv Airport^s^en^Kiev International Airport^^uk^Міжнародний аеропорт «Київ» (Жуляни)^^ru^Аэропорт «Киев» (Жуляны)^^ru^Международный аеропорт «Киев» (Жуляни)^
# IEV-C^IEV^ZZZZ^Y^703448^Kiev^Kiev^Chijv ...^50.401694^30.449697^P^PPLC^UA^^12^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-08-18^N^N^IEV^^EURAS^C^http://en.wikipedia.org/wiki/Kiev^eo^Kievo^
#
{
	# Initialisation
	delete alt_name_list

	# (1) Primary key (IATA code, location type)
	pk = tolower ($1)

	# Transform the IATA code into lower case characters
	iata_code = tolower ($2)

	# Extract the ASCII version of the English name (field #7).
	place_name = tolower ($7)
	alt_name_list["en"] = place_name

	# Extract the UTF8 version of the English name (field #6).
	# When the UTF8 version differs from the ASCII one, add the former as an
	# alternate name. Otherwise, the UTF8 version is kept empty (no need
	# to duplicate).
	if ($6 != $7) {
		alt_name = tolower ($6)
	} else {
		alt_name = ""
	}
	alt_name_list["en"] = sprintf ("%s", alt_name_list["en"] "^" alt_name)

	# Browse all the alternate names
	if (NF >= 34) {

		# The alternate names are indeed (ISO language code, alternate name)
		# pairs. Note that every alternate name entry has got three fields:
		# the ISO language code, the alternate name itself and a serialised
		# list of flags (whether that alternate name is short, historical, etc).
		for (fld = 34; fld <= NF; fld+=2) {

			# Extract the ISO language code
			alt_iso = tolower ($fld); fld++

			# If null, the language code is considered to be English
			if (alt_iso == "") {
				alt_iso = "en"
			}

			# Extract the alternate name itself
			alt_name = tolower ($fld)

			# Add the alternate name to the list for that language code,
			# only when not already registered (duplicates may happen
			# on Geonames).
			if (match (alt_name_list[alt_iso], alt_name) == 0) {

				if (alt_name_list[alt_iso] == "") {
					# First alternate name for that language code.
					# Note that two empty fields must be inserted at the
					# beginning of the line, equal respectively to ASCII name
					# and UTF names.
					alt_name_list[alt_iso] = sprintf ("%s", "^^" alt_name)

				} else {
					# Alternate name for that language code
					alt_name_list[alt_iso] = \
						sprintf ("%s", alt_name_list[alt_iso] "^" alt_name)
				}
			}
		}
	}

	# Browse all the language codes
	for (iso_idx in alt_name_list) {
		print (iso_idx "^" pk "^" iata_code "^" alt_name_list[iso_idx])
	}
}
