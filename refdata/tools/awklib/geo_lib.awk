##
#

##
# Display a list
function displayList(__paramListType, __paramList) {
	if (length(__paramList) == 0) {
		return
	}

	print (__paramListType ":")
	for (myIdx in __paramList) {
		print (myIdx " => " __paramList[myIdx])
	}
}

##
# Display a 2-dimensional list
function display2dList(__paramListType, __paramList) {
	if (length(__paramList) == 0) {
		return
	}

	print (__paramListType ":")
	for (myCombIdx in __paramList) {
		split (myCombIdx, myIdxArray, SUBSEP)
		myIdx1 = myIdxArray[1]; myIdx2 = myIdxArray[2]
		print ("[" __paramListType "] " myIdx1 ", " myIdx2 " => " \
			   __paramList[myIdx1, myIdx2])
	}
}

##
##
# Display all the geographical-related lists:
# cities, airports, heliports, railway stations, bus stations, ground stations,
# maritime ports and off-line points.
function displayLists() {
	#
	displayList("Cities", city_list)
	displayList("Airports", airport_list)
	displayList("Heliports", heliport_list)
	displayList("Railway stations", rail_list)
	displayList("Bus stations", bus_list)
	displayList("Ground stations", ground_list)
	displayList("Ports", port_list)
	displayList("Off-line points", offpoint_list)

	#
	display2dList("ORI POR indices", ori_por_idx_list)
	display2dList("ORI POR latitude", ori_por_lat_list)
	display2dList("ORI POR longitude", ori_por_lon_list)
	display2dList("ORI POR city list", ori_por_cty_list)
	display2dList("ORI POR beginning date list", ori_por_bdate_list)
}

##
# State whether the POR is (matches with) a city
function isLocTypeCity(__paramLocationType) {
	__resultIsCity = match (__paramLocationType, "[C]")
	return __resultIsCity
}

##
# State whether the POR is travel-related
function isLocTypeTvlRtd(__paramLocationType) {
	__isAirport = match (__paramLocationType, "[A]")
	__isHeliport = match (__paramLocationType, "[H]")
	__isRail = match (__paramLocationType, "[R]")
	__isBus = match (__paramLocationType, "[B]")
	__isGround = match (__paramLocationType, "[G]")
	__isPort = match (__paramLocationType, "[P]")
	__isOffpoint = match (__paramLocationType, "[O]")

	# Aggregation
	__resultIsTravelRelated = __isAirport + __isHeliport + __isRail + __isBus \
		+ __isGround + __isPort + __isOffpoint

	return __resultIsTravelRelated
}

##
# State whether the POR is (matches with) a city
function isFeatCodeCity(__paramFeatureCode) {
	# City, populated place, administrative locality, political entity, island
	__resultIsCity  = match (__paramFeatureCode, "PPL")
	__resultIsCity += match (__paramFeatureCode, "ADM")
	__resultIsCity += match (__paramFeatureCode, "LCTY")
	__resultIsCity += match (__paramFeatureCode, "PCLI")
	__resultIsCity += match (__paramFeatureCode, "ISL")

	return __resultIsCity
}

##
# State whether the POR is an airport (or air field/base or sea plane base)
function isFeatCodeAirport(__paramFeatureCode) {
	# Airport (AIRP)
	__resultIsAirport  = match (__paramFeatureCode, "AIRP")
	# Airfield (AIRF)
	__resultIsAirport += match (__paramFeatureCode, "AIRF")
	# Airbase (AIRB)
	__resultIsAirport += match (__paramFeatureCode, "AIRB")
	# Sea plane base (AIRS), a.k.a. SPB
	__resultIsAirport += match (__paramFeatureCode, "AIRS")

	return __resultIsAirport
}

##
# State whether the POR is an heliport
function isFeatCodeHeliport(__paramFeatureCode) {
	# Heliport
	__resultIsHeliport = match (__paramFeatureCode, "AIRH")

	return __resultIsHeliport
}

##
# State whether the POR is a railway station
function isFeatCodeRail(__paramFeatureCode) {
	# Railway station
	__resultIsRail = match (__paramFeatureCode, "RSTN")

	return __resultIsRail
}

##
# State whether the POR is a bus station or stop
function isFeatCodeBus(__paramFeatureCode) {
	# Bus station (BUSTN) or bus stop (BUSTP)
	__resultIsBus = match (__paramFeatureCode, "BUST")

	return __resultIsBus
}

##
# State whether the POR is a maritime port or ferry or naval base
function isFeatCodePort(__paramFeatureCode) {
	# Naval base (NVB), maritime port (PRT), ferry (FY)
	__resultIsPort  = match (__paramFeatureCode, "NVB")
	__resultIsPort += match (__paramFeatureCode, "PRT")
	__resultIsPort += match (__paramFeatureCode, "FY")

	return __resultIsPort
}

##
# State whether the POR is travel-related
function isFeatCodeTvlRtd(__paramFeatureCode) {
	# Airbase (AIRB), airport (AIRP), airfield (AIRF), sea plane base (AIRS)
	__isAirport  = isFeatCodeAirport(__paramFeatureCode)

	# Heliport
	__isHeliport = isFeatCodeHeliport(__paramFeatureCode)

	# Railway station
	__isRail = isFeatCodeRail(__paramFeatureCode)

	# Bus station or bus stop
	__isBus = isFeatCodeBus(__paramFeatureCode)

	# Naval base, maritime port or ferry
	__isPort  = isFeatCodePort(__paramFeatureCode)


	# Aggregation
	__resultIsTravelRelated = __isAirport + __isHeliport + __isRail + __isBus \
		+ __isPort

	return __resultIsTravelRelated
}

##
# Derive the Geonames feature class.
# See also http://www.geonames.org/export/codes.html
function getFeatureClass(__paramLocationType) {
	__resultFeatureClass = "NA"

	switch (__paramLocationType) {
	case "C": case "O":
		__resultFeatureClass = "P"
		break
	case "A": case "H": case "R": case "B": case "P": case "G": \
		__resultFeatureClass = "S"
		break
	}

	return __resultFeatureClass
}

##
# Derive the Geonames feature code.
# See also http://www.geonames.org/export/codes.html
function getFeatureCode(__paramLocationType) {
	__resultFeatureCode = "NA"

	switch (__paramLocationType) {
	case "C": case "O":
		__resultFeatureCode = "PPL"
		break
	case "A":
		__resultFeatureCode = "AIRP"
		break
	case "H":
		__resultFeatureCode = "AIRH"
		break
	case "R":
		__resultFeatureCode = "RSTN"
		break
	case "B":
		__resultFeatureCode = "BUSTN"
		break
	case "G":
		__resultFeatureCode = "RSTN"
		break
	case "P":
		__resultFeatureCode = "FY"
		break
	}

	return __resultFeatureCode
}

##
# Derive the ORI/IATA location type.
# See also http://www.geonames.org/export/codes.html
function getLocationType(__paramFeatureCode) {
	__resultLocationType = "NA"

	if (isFeatCodeCity(__paramFeatureCode)) {
		# City
		__resultLocationType = "C"

	} else if (isFeatCodeAirport(__paramFeatureCode)) {
		# Airport
		__resultLocationType = "A"

	} else if (isFeatCodeHeliport(__paramFeatureCode)) {
		# Heliport
		__resultLocationType = "H"

	} else if (isFeatCodeRail(__paramFeatureCode)) {
		# Railway station
		__resultLocationType = "R"

	} else if (isFeatCodeBus(__paramFeatureCode)) {
		# Bus station/stop
		__resultLocationType = "B"

	} else if (isFeatCodePort(__paramFeatureCode)) {
		# Maritime port, ferry, naval base
		__resultLocationType = "P"
	}

	return __resultLocationType
}

##
# Extract the details of the primary key:
# 1. The IATA code
# 2. The ORI-maintained location type
# 3. The ORI-maintained Geonames ID
function extractPrimaryKeyDetails(__paramPK) {
	# Specification of the primary key format
	pk_regexp = "^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$"

	# IATA code (first field of the primary key)
	epkdIataCode = gensub (pk_regexp, "\\1", "g", __paramPK)

	# Location type (second field of the primary key)
	epkdLocationType = gensub (pk_regexp, "\\2", "g", __paramPK)

	# Geonames ID (third field of the primary key)
	epkdGeonamesID = gensub (pk_regexp, "\\3", "g", __paramPK)
}

##
# Extract the primary key fields as an array.
function getPrimaryKeyAsArray(__paramPK, __resultPKArray) {
	__resultNbOfFields = split (__paramPK, __resultPKArray, "-")
	return __resultNbOfFields
}

##
# Extract the primary key fields as an array.
function getPrimaryKey(__paramIataCode, __paramLocationType, __paramGeonamesID) {
	__resultPK = __paramIataCode "-" __paramLocationType "-" __paramGeonamesID
	return __resultPK
}

##
# Add the given location type to the given dedicated ORI list. The location type
# and the list correspond to the file of best known coordinates.
#
function addLocTypeToORIList(__paramIataCode, __paramLocationType,	\
							 __paramORIList) {
	# Register the details of the ORI-maintained POR entry for the latitude
	myTmpString = __paramORIList[__paramIataCode]
	if (myTmpString) {
		myTmpString = myTmpString ","
	}
	myTmpString = myTmpString __paramLocationType
	__paramORIList[__paramIataCode] = myTmpString
}

##
# Add a given field to the given dedicated ORI list. The field and the list
# correspond to the file of best known coordinates and, therefore, are one
# of the following:
# * Latitude
# * Longitude
# * Served city IATA code
# * Beginning date of the validity range
#
function addORIFieldToList(__paramIataCode, __paramLocationType,	\
						   __paramORIList, __paramORIField) {
	# Register the details of the ORI-maintained POR entry for the latitude
	myTmpString = __paramORIList[__paramIataCode, __paramLocationType]
	if (myTmpString) {
		myTmpString = myTmpString ","
	}
	myTmpString = myTmpString __paramORIField
	__paramORIList[__paramIataCode, __paramLocationType] = myTmpString
}

##
# Register the details of the ORI-maintained POR entry. Those details are:
# 1. The primary key:
# 1.1. The IATA code
# 1.2. The ORI-maintained location type
# 1.3. The ORI-maintained Geonames ID
# 2. The IATA code of the POR itself
# 3. The geographical coordinates (latitude and longitude)
# 4. The IATA code of the served city
# 5. The beginning date of the validity range.
#    When blank, it has always been valid.
#
# Note 1: the location type is either individual (e.g., 'C', 'A', 'H', 'R', 'B',
#         'P', 'G', 'O') or combined (e.g., 'CA', 'CH', 'CR', 'CB', 'CP')
#
function registerORILine(__paramPK, __paramIataCode2,					\
						 __paramLatitude, __paramLongitude,				\
						 __paramServedCityCode, __paramBeginDate,		\
						 __paramFullLine, __paramAWKFile, __paramErrorStream) {
	# Extract the primary key fields
	getPrimaryKeyAsArray(__paramPK, myPKArray)
	rolIataCode = myPKArray[1]
	rolLocationType = myPKArray[2]
	rolGeonamesID = myPKArray[3]

	# Analyse the location type
	myIsCity = isLocTypeCity(rolLocationType)
	myIsTravel = isLocTypeTvlRtd(rolLocationType)

	# DEBUG
	# print ("PK=" __paramPK ", IATA code=" rolIataCode ", loc_type="		\
	#	   rolLocationType ", GeoID=" rolGeonamesID ", srvd city="		\
	#	   __paramServedCityCode ", beg date=" __paramBeginDate ", awk=" \
	#	   awk_file ", err=" error_stream)

	# Sanity check: the IATA codes of the primary key and of the dedicated field
	#               should be equal.
	if (rolIataCode != __paramIataCode2) {
		print ("[" __paramAWKFile "] !!!! Error at line #" FNR			\
			   ", the IATA code ('" rolIataCode "') of the primary key " \
			   "is not the same as the one of the dedicated field ('"	\
			   __paramIataCode2 "') - Full line: " __paramFullLine)		\
			> __paramErrorStream
	}

	# Sanity check: when the location type is a combined type, one of those
	#               types should be a travel-related POR.
	if (length(rolLocationType) >= 2 && myIsTravel == 0) {
		print ("[" __paramAWKFile "] !!!! Error at line #" FNR			\
			   ", the location type ('"	rolLocationType					\
			   "') is unknown - Full line: " __paramFullLine)			\
			> __paramErrorStream
	}

	# Add the location type to the dedicated list for that IATA code
	addLocTypeToORIList(rolIataCode, rolLocationType, ori_por_loctype_list)

	# Calculate the index for that IATA code
	ori_por_idx_list[rolIataCode, rolLocationType]++
	ori_por_idx = ori_por_idx_list[rolIataCode, rolLocationType]

	# Register the details of the ORI-maintained POR entry for the latitude
	addORIFieldToList(rolIataCode, rolLocationType,			\
					  ori_por_lat_list, __paramLatitude)

	# Register the details of the ORI-maintained POR entry for the longitude
	addORIFieldToList(rolIataCode, rolLocationType,			\
					  ori_por_lon_list, __paramLongitude)

	# Register the details of the ORI-maintained POR entry for the served city
	addORIFieldToList(rolIataCode, rolLocationType,			\
					  ori_por_cty_list, __paramServedCityCode)

	# Register the details of the ORI-maintained POR entry for the beg. date
	addORIFieldToList(rolIataCode, rolLocationType,			\
					  ori_por_bdate_list, __paramBeginDate)
}

##
# Reset the list of the ORI-maintained POR entries
function resetORILineList() {
	delete ori_por_loctype_list
 	delete ori_por_idx_list
	delete ori_por_lat_list
	delete ori_por_lon_list
	delete ori_por_cty_list
	delete ori_por_bdate_list
}

##
# Reset the list of last Geonames POR entries
function resetGeonamesLineList() {
	delete geo_line_idx_list
	delete geo_line_list
}

##
# Suggest a next step for the user: add the given POR entry
function displayNextStepAdd(__paramIataCode, __paramFeatureCode,	\
							__paramGeonamesID,						\
							__paramAWKFile, __paramErrorStream) {
	# Calculate the location type
	dnsaLocationType = getLocationType(__paramFeatureCode)

	# Calculate the primary key
	dnsaPK = getPrimaryKey(__paramIataCode, dnsLocationType, __paramGeonamesID)

	#
	print ("[" __paramAWKFile "] Next step: add an entry in the ORI file of " \
		   "best known coordinates for the " dnsaPK " primary key")		\
		> __paramErrorStream
}

##
# Suggest a next step for the user: fix the location type of the given POR entry
function displayNextStepFix(__paramIataCode, __paramFeatureCode,	\
							__paramGeonamesID,						\
							__paramAWKFile, __paramErrorStream) {
	# Calculate the location type
	dnsfLocationType = getLocationType(__paramFeatureCode)

	# Calculate the primary key
	dnsfPK = getPrimaryKey(__paramIataCode, dnsfLocationType, __paramGeonamesID)

	#
	print ("[" __paramAWKFile "] Next step: fix the entry in the ORI file of " \
		   "best known coordinates for the " dnsfPK " primary key")		\
		> __paramErrorStream
}


##
# Register the full Geonames POR entry details for the given primary key:
# 1. The IATA code
# 2. The ORI-maintained location type
# 3. The ORI-maintained Geonames ID
function registerGeonamesLine(__paramIataCode, __paramFeatureCode,	\
							  __paramGeonamesID, __paramFullLine,	\
							  __paramAWKFile, __paramErrorStream,	\
							  __paramLogLevel, __paramNbOfPOR) {

	# Derive the location type from the feature code.
	# Note: by design of a Geonames POR entry, its location type is individual.
	#       However, the POR entry may have been registered in the ORI list as
	#       combined. In that latter case, a 'C' has to be added in front of
	#       the travel-related location type. For instance, 'A' => 'CA'.
	rglLocationType = getLocationType(__paramFeatureCode)
	if (isLocTypeTvlRtd(rglLocationType)) {
		rglAltLocationType = "C" rglLocationType
	} else if (isLocTypeCity(rglLocationType)) {
		rglAltLocationType = "O"
	}

	# Sanity check: the location type should be known
	if (rglLocationType == "NA") {
  		print ("[" __paramAWKFile "] !!!! Error at line #" __paramNbOfPOR \
			   ", the POR with that IATA code ('" __paramIataCode		\
			   "') has an unknown feature code ('" __paramFeatureCode	\
			   "') - Full line: " __paramFullLine) > __paramErrorStream
		return
	}

	# Check whether that IATA code and location type are known from ORI
	ori_por_idx = ori_por_idx_list[__paramIataCode, rglLocationType]
	ori_por_cmb_idx = ori_por_idx_list[__paramIataCode, rglAltLocationType]

	# Sanity check: the POR should be known by ORI
	if (ori_por_idx + ori_por_cmb_idx == 0) {

		# Extract the list of location types that ORI may know
		rglLocTypeList = ori_por_loctype_list[__paramIataCode]
		if (rglLocTypeList == "") {
			# The ORI-maintained list of POR has no entry with that IATA code

			# Notification
			if (__paramLogLevel >= 4) {
				print ("[" __paramAWKFile "] !!!! Error at line #" FNR	\
					   ", the POR with that IATA code ('" __paramIataCode \
					   "') is not referenced in the ORI-maintained list, be it" \
					   " with the individual location type ('" rglLocationType \
					   "') or the alternate location type ('"			\
					   rglAltLocationType "'). Full line: "				\
					   __paramFullLine) > __paramErrorStream
				displayNextStepAdd(__paramIataCode, __paramFeatureCode,	\
								   __paramGeonamesID,					\
								   __paramAWKFile, __paramErrorStream)
			}
			return
		}

		# split (rglLocTypeList, rglLocTypeArray, SUBSEP)
		# for (rglLocType in rglLocTypeArray) { }
		# Notification
		if (__paramLogLevel >= 5) {
			print ("[" __paramAWKFile "] !!!! Notification at line #" FNR \
				   ", the POR with that IATA code ('" __paramIataCode	\
				   "') is referenced in the ORI-maintained list, but with " \
				   "a different location type (among '" rglLocTypeList	\
				   "') than the Geonames' one ('" rglLocationType		\
				   "'). Full line: " __paramFullLine) > __paramErrorStream
			displayNextStepFix(__paramIataCode, __paramFeatureCode,		\
							   __paramGeonamesID,						\
							   __paramAWKFile, __paramErrorStream)
		}
	}

	# Display the last read POR entry, when:
	# 1. The current POR entry is not the first one (as the last POR entry
	#    then is not defined).
	# 2. The current POR entry has got a (IATA code, location type) combination
	#    distinct from the last POR entry.
	if ((__paramIataCode, rglLocationType) in geo_line_idx_list	\
		|| __paramNbOfPOR == 1) {

	} else {
		# Display the last Geonames POR entries
		displayGeonamesPOREntries(__paramAWKFile, __paramErrorStream,	\
								  __paramLogLevel)

		# Reset the list for the next turn
		resetGeonamesLineList()
	}

	# Register the Geonames POR entry in the list of last entries
	# for that IATA code
	geo_line_idx_list[__paramIataCode, rglLocationType]++
	geo_line_list[__paramGeonamesID] = __paramFullLine
}

##
# Display the list of Geonames POR entries.
# Usually, there is no more than one POR entry for a given IATA code
# and location type.
#
# In some rare cases, a travel-related POR serves several cities. For instance,
# RDU-A-4487056 serves both RDU-C-4464368 (Raleigh) and RDU-C-4487042 (Durham)
# in North Carolina, USA. In that case, there are two entries for RDU-C.
#
function displayGeonamesPOREntries(__paramAWKFile, __paramErrorStream, \
								   __paramLogLevel) {

	# Calculate the number of the last Geonames POR entries. Most of the time,
	# that number should be one.
	dgpeNbOfPOR = length(geo_line_idx_list)

	# Sanity check: by construction, there should be no more than one Geonames
	#               POR entry for the (IATA code, location type) combination
	if (dgpeNbOfPOR != 1) {
  		print ("[" __paramAWKFile "] !!!! Error at line #" FNR	\
			   ", the number of last Geonames POR entries (" dgpeNbOfPOR \
			   ") is not exactly one (1).") > __paramErrorStream
		return
	}

	# Extract the IATA code and location type
	for (dgpeCombIdx in geo_line_idx_list) {
		split (dgpeCombIdx, dgpeIdxArray, SUBSEP)
		dgpeIataCode = dgpeIdxArray[1]
		dgpeLocationType = dgpeIdxArray[2]
	}

	# Calculate the number of the last Geonames POR entries. Most of the time,
	# that number should be one.
	dgpeNbOfGeoID = length(geo_line_list)

	# Notification
	if (dgpeNbOfGeoID >= 2 && __paramLogLevel >= 5) {
  		print ("[" __paramAWKFile "] !!!! Notification at line #" FNR	\
			   ", the number of last Geonames POR entries (" dgpeNbOfGeoID \
			   ") is greater than one for that (" dgpeIataCode ", "		\
			   dgpeLocationType ") combination.") > __paramErrorStream
	}

	# Browse the last registered Geonames POR entries
	for (dgpeGeonamesPORIdx in geo_line_list) {
		dgpePK = getPrimaryKey(dgpeIataCode, dgpeLocationType, \
							   dgpeGeonamesPORIdx)
		dgpeGeonamesPORLine = dgpePK FS geo_line_list[dgpeGeonamesPORIdx]

		#
		print (dgpeGeonamesPORLine)
	}

	return
}
