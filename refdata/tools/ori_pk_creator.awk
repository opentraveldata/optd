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
#  * 'H' for heliport
#  * 'R' for railway station
#  * 'B' for bus station,
#  * 'P' for maritime port
#  * 'G' for ground station
#  * 'O' for off-line point (usually small airports or railway stations)
#
# That script relies on the ORI-maintained list of POR (points of reference),
# provided by the OpenTravelData project (http://github.com/opentraveldata/optd).
# Issue the 'prepare_ori_public.sh --ori' command to see more detailed
# instructions.
#
# All the work has indeed already been done by ORI and integrated within the
# ORI-maintained list of POR file, namely 'ori_por_public.csv'. Hence, the
# primary key is just the concatenation of the IATA code and location type.
# No more work to do at that stage.
#

##
# Header
/^iata_code/ {
	print ("pk^" $0)
}

##
# Regular 'ori_por_public.csv' line
# Details of the fields:
# iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id
# ^name^asciiname^latitude^longitude^fclass^fcode
# ^page_rank^date_from^date_until^comment
# ^country_code^cc2^country_name
# ^adm1_code^adm1_name_utf^adm1_name_ascii
# ^adm2_code^adm2_name_utf^adm2_name_ascii
# ^adm3_code^adm4_code
# ^population^elevation^gtopo30
# ^timezone^gmt_offset^dst_offset^raw_offset^moddate
# ^is_airport^is_commercial
# ^city_code^city_name_utf^city_name_ascii
# ^state_code^region_code^location_type
# ^wiki_link
# ^alt_name_section
#
# Sample lines:
# ARN^ESSA^^Y^2725346^^Stockholm-Arlanda Airport^Stockholm-Arlanda Airport^59.651944^17.918611^S^AIRP^0.255578965703^^^^SE^^Sweden^26^Stockholm^Stockholm^0191^Sigtuna Kommun^Sigtuna Kommun^^^0^41^42^Europe/Stockholm^1.0^2.0^1.0^2012-07-01^Y^Y^STO^^^^EUROP^A^http://en.wikipedia.org/wiki/Stockholm-Arlanda_Airport^en|Stockholm-Arlanda Airport|
# ARN^ZZZZ^^Y^8335457^^Arlanda Central Station^Arlanda Central Station^59.649463^17.929^S^RSTN^0.255578965703^^^^SE^^Sweden^26^Stockholm^Stockholm^0191^Sigtuna Kommun^Sigtuna Kommun^019106^0032^0^^27^Europe/Stockholm^1.0^2.0^1.0^2012-07-01^N^Y^STO^^^^EUROP^R^http://en.wikipedia.org/wiki/Arlanda_North_Station^en|Arlanda Central Station|
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Y^Y^IEV^^^^EURAS^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=ru|Аэропорт «Киев» (Жуляны)|
# IEV^ZZZZ^^Y^703448^^Kiev^Kiev^50.401694^30.449697^P^PPLC^0.110013254093^^^^UA^^Ukraine^12^Kyiv City^Kyiv City^^^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-10-23^N^N^IEV^^^^EURAS^C^http://en.wikipedia.org/wiki/Kiev^en|Kiev|h=ru|Киев|
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Y^Y^NCE^^^^EUROP^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Côte d'Azur International Airport|=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
#
/^([A-Z]{3})\^([A-Z0-9]{0,4})\^([A-Z0-9]{0,4})\^([YN])/ {
	# IATA code
	iata_code = $1

	# Location type
	location_type = $43

	# Primary key (IATA code - location type)
	pk = iata_code "-" location_type

	#
	print (pk "^" $0)
}

