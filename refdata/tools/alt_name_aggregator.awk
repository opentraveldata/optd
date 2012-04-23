##
# Aggregate the language (e.g., 'en') alternate names on a single line.
# The alternate names of the same POR, specified as having the same IATA
# and ICAO codes, as well as the same Geonames ID.

BEGIN {
	whole_line = ""
}

##
# M A I N
{
	if (iata_code == $1 && icao_code == $2 && geo_id == $3) {
		# The current POR is the same as the previous one. So, add the
		# alternate name to the list of alternate names of that POR.
		if ($NF != "NULL") {
			whole_line = whole_line "^" $NF
		}
		
	} else {
		# The current POR is different from the previous one. It is therefore
		# time to print that line (POR details).
		if (whole_line != "") {
			#
			printf ("%s\n", whole_line)
		}

		# Remove any trailing "^NULL" field. Decrementing NF reduces $0 as well.
		OFS = FS
		if ($NF == "NULL") {
			NF--
		}

		#
		whole_line = $0
	}

	# Iteration
	iata_code = $1 ; icao_code = $2 ; geo_id = $3
}

##
#
END {
	printf ("%s\n", whole_line)
}
