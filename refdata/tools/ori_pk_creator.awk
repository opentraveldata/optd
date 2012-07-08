##
# That AWK script creates and adds a primary key for the ORI-maintained list
# of POR (points of reference).
# The primary key is made of the IATA code and location type. For instance:
#  * ARN-A means the Arlanda airport in Stockholm, Sweden
#  * ARN-R means the Arlanda railway station in Stockholm, Sweden
#  * CDG-A means the Charles de Gaulle airport in Paris, France
#  * PAR-C means the city of Paris, France
#  * NCE-CA means Nice, France, indifferentiating the airport from the city
#  * SFO-A means the San Francisco airport, California, US
#  * SFO-C means the city of San Francisco, California, US
#
# A few examples of IATA location types:
#  * 'C' for city
#  * 'A' for airport
#  * 'CA' for a combination of both
#  * 'R' for railway station
#  * 'B' for bus station,
#  * 'O' for off-line point (usually small airports or railway stations)
#
# That script relies on the ORI-maintained list of POR (points of reference),
# provided by the OpenTravelData project (http://github.com/opentraveldata/optd).
# Issue the 'prepare_ori_public.sh --ori' command to see more detailed instructions.
#
# All the work has indeed already been done by ORI and integrated within the
# ORI-maintained list of POR file, namely 'ori_por_public.csv'. Hence, the primary key
# is just the concatenation of the IATA code and location type. No more work to do
# at that stage.
#

##
# Header
/^iata_code/ {
	print ("pk^" $0)
}

##
# Regular 'ori_por_public.csv' line
# Sample lines:
# ARN^ESSA^Y^2725346^Stockholm-Arlanda Airport^Stockholm-Arlanda Airport^ARN,...^59.651944^17.918611^S^AIRP^SE^^26^0191^^^0^41^42^Europe/Stockholm^1.0^2.0^1.0^2012-07-01^Y^Y^STO^^EUROP^A^http://en.wikipedia.org/wiki/Stockholm-Arlanda_Airport^en^Stockholm-Arlanda Airport
# ARN^ZZZZ^Y^8335457^Arlanda Central Station^Arlanda Central Station^ARN,...^59.649463^17.929^S^RSTN^SE^^26^0191^019106^0032^0^0^27^Europe/Stockholm^1.0^2.0^1.0^2012-07-01^N^Y^STO^^EUROP^R^http://en.wikipedia.org/wiki/Arlanda_North_Station^en^Arlanda Central Station
# IEV^UKKK^Y^6300960^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^Aehroport «Kiev» (Zhuljany),...^50.401694^30.449697^S^AIRP^UA^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Y^Y^IEV^^EURAS^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en^Kyiv Zhuliany International Airport
# IEV^ZZZZ^Y^703448^Kiev^Kiev^Chijv,...^50.401694^30.449697^P^PPLC^UA^^12^^^^2514227^0^187^Europe/Kiev^2.0^3.0^2.0^2012-01-31^N^N^IEV^^EURAS^C^
# NCE^LFMN^Y^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^Aeroport de Nice Cote d'Azur,...^43.658411^7.215872^S^AIRP^FR^^B8^06^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Y^Y^NCE^^EUROP^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en^Nice Airport^en^Nice Côte d'Azur International Airport
#
/^([A-Z]{3})\^([A-Z0-9]{4})\^([YN])/ {
	# IATA code
	iata_code = $1

	# Location type
	location_type = $31

	# Primary key (IATA code - location type)
	pk = iata_code "-" location_type

	#
	print (pk "^" $0)
}

