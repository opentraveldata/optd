##
#
# Header
BEGIN {
	printf ("language_code^iata_code^ascii_name^utf_name")
	printf ("^alternate_name1^alternate_name2^alternate_name3^alternate_name4")
	printf ("^alternate_name5^alternate_name6^alternate_name7^alternate_name8")
	printf ("^alternate_name9^alternate_name10")
	printf ("\n")
}

## M A I N
{
	# Transform the IATA code into lower case characters
	# iata_code = $1
	iata_code = tolower ($1)

	# For now, just get the ASCII version of the English name.
	# place_name = $6
	place_name = tolower ($6)

	# Language code ^ IATA code ^ English name, ASCII version
	printf ("en" "^" iata_code "^" place_name)

	# ^ Alternate name
	# When the ASCII version differs from the UTF8 one, add that latter as an
	# alternate name
	if ($5 != $6) {
		# alt_name = $5
		alt_name = tolower ($5)
		printf ("^%s", alt_name)
	}

	# When there are alternate names, print them
	if (NF >= 32) {
		#
		for (fld = 32; fld <= NF; fld++) {
			alt_name = tolower ($fld)
			printf ("^%s", alt_name)
		}
	}

	# End of line
	printf ("\n")
}
