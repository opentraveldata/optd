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
function isLocTypeCity(__iltcParamLocationType) {
	__resultIsCity = match (__iltcParamLocationType, "[C]")
	return __resultIsCity
}

##
# State whether the POR is travel-related
function isLocTypeTvlRtd(__ilttrParamLocationType) {
	__isAirport = match (__ilttrParamLocationType, "[A]")
	__isHeliport = match (__ilttrParamLocationType, "[H]")
	__isRail = match (__ilttrParamLocationType, "[R]")
	__isBus = match (__ilttrParamLocationType, "[B]")
	__isGround = match (__ilttrParamLocationType, "[G]")
	__isPort = match (__ilttrParamLocationType, "[P]")
	__isOffpoint = match (__ilttrParamLocationType, "[O]")

	# Aggregation
	__resultIsTravelRelated = __isAirport + __isHeliport + __isRail + __isBus \
		+ __isGround + __isPort + __isOffpoint

	return __resultIsTravelRelated
}

##
# State whether the POR is (matches with) a city
function isFeatCodeCity(__ifccParamFeatureCode) {
	# City, populated place, administrative locality, political entity, island
	__resultIsCity  = match (__ifccParamFeatureCode, "PPL")
	__resultIsCity += match (__ifccParamFeatureCode, "ADM")
	__resultIsCity += match (__ifccParamFeatureCode, "LCTY")
	__resultIsCity += match (__ifccParamFeatureCode, "PCLI")
	__resultIsCity += match (__ifccParamFeatureCode, "ISL")

	return __resultIsCity
}

##
# State whether the POR is an airport (or air field/base or sea plane base)
function isFeatCodeAirport(__ifcaParamFeatureCode) {
	# Airport (AIRP)
	__resultIsAirport  = match (__ifcaParamFeatureCode, "AIRP")
	# Airfield (AIRF)
	__resultIsAirport += match (__ifcaParamFeatureCode, "AIRF")
	# Airbase (AIRB)
	__resultIsAirport += match (__ifcaParamFeatureCode, "AIRB")
	# Sea plane base (AIRS), a.k.a. SPB
	__resultIsAirport += match (__ifcaParamFeatureCode, "AIRS")

	return __resultIsAirport
}

##
# State whether the POR is an heliport
function isFeatCodeHeliport(__ifchParamFeatureCode) {
	# Heliport
	__resultIsHeliport = match (__ifchParamFeatureCode, "AIRH")

	return __resultIsHeliport
}

##
# State whether the POR is a railway station
function isFeatCodeRail(__ifcrParamFeatureCode) {
	# Railway station
	__resultIsRail = match (__ifcrParamFeatureCode, "RSTN")

	return __resultIsRail
}

##
# State whether the POR is a bus station or stop
function isFeatCodeBus(__ifcbParamFeatureCode) {
	# Bus station (BUSTN) or bus stop (BUSTP)
	__resultIsBus = match (__ifcbParamFeatureCode, "BUST")

	return __resultIsBus
}

##
# State whether the POR is a maritime port or ferry or naval base
function isFeatCodePort(__ifcpParamFeatureCode) {
	# Naval base (NVB), maritime port (PRT), ferry (FY)
	__resultIsPort  = match (__ifcpParamFeatureCode, "NVB")
	__resultIsPort += match (__ifcpParamFeatureCode, "PRT")
	__resultIsPort += match (__ifcpParamFeatureCode, "FY")

	return __resultIsPort
}

##
# State whether the POR is travel-related
function isFeatCodeTvlRtd(__ifctrParamFeatureCode) {
	# Airbase (AIRB), airport (AIRP), airfield (AIRF), sea plane base (AIRS)
	__isAirport  = isFeatCodeAirport(__ifctrParamFeatureCode)

	# Heliport
	__isHeliport = isFeatCodeHeliport(__ifctrParamFeatureCode)

	# Railway station
	__isRail = isFeatCodeRail(__ifctrParamFeatureCode)

	# Bus station or bus stop
	__isBus = isFeatCodeBus(__ifctrParamFeatureCode)

	# Naval base, maritime port or ferry
	__isPort  = isFeatCodePort(__ifctrParamFeatureCode)


	# Aggregation
	__resultIsTravelRelated = __isAirport + __isHeliport + __isRail + __isBus \
		+ __isPort

	return __resultIsTravelRelated
}

##
# Derive the Geonames feature class.
# See also http://www.geonames.org/export/codes.html
function getFeatureClass(__gfcParamLocationType) {
	__resultFeatureClass = "NA"

	switch (__gfcParamLocationType) {
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
function getFeatureCode(__gfcParamLocationType) {
	__resultFeatureCode = "NA"

	switch (__gfcParamLocationType) {
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
function getLocationType(__gltParamFeatureCode) {
	__resultLocationType = "NA"

	if (isFeatCodeCity(__gltParamFeatureCode)) {
		# City
		__resultLocationType = "C"

	} else if (isFeatCodeAirport(__gltParamFeatureCode)) {
		# Airport
		__resultLocationType = "A"

	} else if (isFeatCodeHeliport(__gltParamFeatureCode)) {
		# Heliport
		__resultLocationType = "H"

	} else if (isFeatCodeRail(__gltParamFeatureCode)) {
		# Railway station
		__resultLocationType = "R"

	} else if (isFeatCodeBus(__gltParamFeatureCode)) {
		# Bus station/stop
		__resultLocationType = "B"

	} else if (isFeatCodePort(__gltParamFeatureCode)) {
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
function extractPrimaryKeyDetails(__epkdParamPK) {
	# Specification of the primary key format
	pk_regexp = "^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$"

	# IATA code (first field of the primary key)
	epkdIataCode = gensub (pk_regexp, "\\1", "g", __epkdParamPK)

	# Location type (second field of the primary key)
	epkdLocationType = gensub (pk_regexp, "\\2", "g", __epkdParamPK)

	# Geonames ID (third field of the primary key)
	epkdGeonamesID = gensub (pk_regexp, "\\3", "g", __epkdParamPK)
}

##
# Extract the primary key fields as an array.
function getPrimaryKeyAsArray(__gpkaaParamPK, __resultPKArray) {
	__resultNbOfFields = split (__gpkaaParamPK, __resultPKArray, "-")
	return __resultNbOfFields
}

##
# Extract the primary key fields as an array.
function getPrimaryKey(__gpkParamIataCode, __gpkParamLocationType, \
					   __gpkParamGeonamesID) {
	__resultPK = \
		__gpkParamIataCode "-" __gpkParamLocationType "-" __gpkParamGeonamesID
	return __resultPK
}

##
# Add the given location type to the given dedicated ORI list. The location type
# and the list correspond to the file of best known coordinates.
#
function addLocTypeToORIList(__alttolParamIataCode, __alttolParamLocationType, \
							 __alttolParamORIList) {
	# Register the details of the ORI-maintained POR entry for the latitude
	myTmpString = __alttolParamORIList[__alttolParamIataCode]
	if (myTmpString) {
		myTmpString = myTmpString ","
	}
	myTmpString = myTmpString __alttolParamLocationType
	__alttolParamORIList[__alttolParamIataCode] = myTmpString
}

##
# Add the given Geonames ID to the given dedicated ORI list. The Geonames ID
# and the list correspond to the file of best known coordinates.
#
function addGeoIDToORIList(__agitolParamIataCode, __agitolParamLocationType, \
						   __agitolParamGeonamesID, __agitolParamORIList) {
	# Register the details of the ORI-maintained POR entry for the latitude
	myTmpString = \
		__agitolParamORIList[__agitolParamIataCode, __agitolParamLocationType]
	if (myTmpString) {
		myTmpString = myTmpString ","
	}
	myTmpString = myTmpString __agitolParamGeonamesID
	__agitolParamORIList[__agitolParamIataCode, __agitolParamLocationType] = \
		myTmpString
}

##
# Add the given Geonames ID to the given dedicated Geonames list. The Geonames ID
# and the list correspond to the Geonames data dump.
#
function addGeoIDToGeoList(__agitolParamLocationType, __agitolParamGeonamesID, \
						   __agitolParamGeoList) {
	# Register the details of the ORI-maintained POR entry for the latitude
	myTmpString = __agitolParamGeoList[__agitolParamLocationType]
	if (myTmpString) {
		myTmpString = myTmpString ","
	}
	myTmpString = myTmpString __agitolParamGeonamesID
	__agitolParamGeoList[__agitolParamLocationType] = myTmpString
}

##
# Add the given Geonames ID to the given dedicated Geonames list. The Geonames ID
# and the list correspond to the Geonames data dump.
#
function addLocTypeToGeoList(__alttglParamLocationType, __alttglParamGeoString) {
	__resultGeoString = __alttglParamGeoString

	# If the location type is already listed, do not add it again
	if (match (__alttglParamGeoString, __alttglParamLocationType)) {
		return __resultGeoString
	}

	# Register the location type
	if (__resultGeoString) {
		__resultGeoString = __resultGeoString ","
	}
	__resultGeoString = __resultGeoString __alttglParamLocationType
	return __resultGeoString
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
function addORIFieldToList(__aoftlParamIataCode, __aoftlParamLocationType,	\
						   __aoftlParamORIList, __aoftlParamORIField) {
	# Register the details of the ORI-maintained POR entry for the latitude
	myTmpString = \
		__aoftlParamORIList[__aoftlParamIataCode, __aoftlParamLocationType]
	if (myTmpString) {
		myTmpString = myTmpString ","
	}
	myTmpString = myTmpString __aoftlParamORIField
	__aoftlParamORIList[__aoftlParamIataCode, __aoftlParamLocationType] = \
		myTmpString
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
function registerORILine(__rolParamPK, __rolParamIataCode2,				\
						 __rolParamLatitude, __rolParamLongitude,		\
						 __rolParamServedCityCode, __rolParamBeginDate,	\
						 __rolParamFullLine, __rolParamAWKFile, \
						 __rolParamErrorStream) {
	# Extract the primary key fields
	getPrimaryKeyAsArray(__rolParamPK, myPKArray)
	rolIataCode = myPKArray[1]
	rolLocationType = myPKArray[2]
	rolGeonamesID = myPKArray[3]

	# Analyse the location type
	myIsCity = isLocTypeCity(rolLocationType)
	myIsTravel = isLocTypeTvlRtd(rolLocationType)

	# DEBUG
	# print ("PK=" __rolParamPK ", IATA code=" rolIataCode ", loc_type=" \
	#	   rolLocationType ", GeoID=" rolGeonamesID ", srvd city="		\
	#	   __rolParamServedCityCode ", beg date=" __rolParamBeginDate ", awk=" \
	#	   awk_file ", err=" error_stream)

	# Sanity check: the IATA codes of the primary key and of the dedicated field
	#               should be equal.
	if (rolIataCode != __rolParamIataCode2) {
		print ("[" __rolParamAWKFile "] !!!! Error at line #" FNR		\
			   ", the IATA code ('" rolIataCode "') of the primary key " \
			   "is not the same as the one of the dedicated field ('"	\
			   __rolParamIataCode2 "') - Full line: " __rolParamFullLine) \
			> __rolParamErrorStream
	}

	# Sanity check: when the location type is a combined type, one of those
	#               types should be a travel-related POR.
	if (length(rolLocationType) >= 2 && myIsTravel == 0) {
		print ("[" __rolParamAWKFile "] !!!! Error at line #" FNR		\
			   ", the location type ('"	rolLocationType					\
			   "') is unknown - Full line: " __rolParamFullLine)		\
			> __rolParamErrorStream
	}

	# Add the location type to the dedicated list for that IATA code
	addLocTypeToORIList(rolIataCode, rolLocationType, ori_por_loctype_list)

	# Add the Geonames ID to the dedicated list for that (IATA code, location
	# type)
	addGeoIDToORIList(rolIataCode, rolLocationType, rolGeonamesID,	\
					  ori_por_geoid_list)

	# Calculate the index for that IATA code
	ori_por_idx_list[rolIataCode, rolLocationType]++
	ori_por_idx = ori_por_idx_list[rolIataCode, rolLocationType]

	# Register the details of the ORI-maintained POR entry for the latitude
	addORIFieldToList(rolIataCode, rolLocationType,			\
					  ori_por_lat_list, __rolParamLatitude)

	# Register the details of the ORI-maintained POR entry for the longitude
	addORIFieldToList(rolIataCode, rolLocationType,				\
					  ori_por_lon_list, __rolParamLongitude)

	# Register the details of the ORI-maintained POR entry for the served city
	addORIFieldToList(rolIataCode, rolLocationType,					\
					  ori_por_cty_list, __rolParamServedCityCode)

	# Register the details of the ORI-maintained POR entry for the beg. date
	addORIFieldToList(rolIataCode, rolLocationType,				\
					  ori_por_bdate_list, __rolParamBeginDate)
}

##
# Reset the list of the ORI-maintained POR entries
function resetORILineList() {
	delete ori_por_loctype_list
	delete ori_por_geoid_list
 	delete ori_por_idx_list
	delete ori_por_lat_list
	delete ori_por_lon_list
	delete ori_por_cty_list
	delete ori_por_bdate_list
}

##
# Reset the list of last Geonames POR entries
function resetGeonamesLineList() {
	delete geo_line_list
	delete geo_line_geoid_list
	geo_line_loctype_list = ""
}

##
# Suggest a next step for the user: add the given POR entry
function displayNextStepAdd(__dnsaParamIataCode, __dnsaParamLocationType, \
							__dnsaParamGeonamesID,						\
							__dnsaParamAWKFile, __dnsaParamErrorStream) {
	# Calculate the primary key
	dnsaPK = getPrimaryKey(__dnsaParamIataCode, __dnsaParamLocationType, \
						   __dnsaParamGeonamesID)

	#
	print ("[" __dnsaParamAWKFile "] Next step: add an entry in the ORI " \
		   "file of best known coordinates for the " dnsaPK " primary key")	\
		> __dnsaParamErrorStream
}

##
# Suggest a next step for the user: fix the location type of the given POR entry
function displayNextStepFixLocType(__dnsfltParamIataCode,				\
								   __dnsfltParamLocationType,			\
								   __dnsfltParamGeonamesID,				\
								   __dnsfltParamAWKFile,				\
								   __dnsfltParamErrorStream) {
	# Calculate the primary key
	dnsfPK = getPrimaryKey(__dnsfltParamIataCode, __dnsfltParamLocationType, \
						   __dnsfltParamGeonamesID)

	#
	print ("[" __dnsfltParamAWKFile "] Next step: fix the entry in the ORI " \
		   "file of best known coordinates for the " dnsfPK " primary key")	\
		> __dnsfltParamErrorStream
}

##
# Suggest a next step for the user: fix the Geonames ID of the given POR entry
function displayNextStepFixID(__dnsfiParamIataCode, __dnsfiParamLocationType, \
							  __dnsfiParamGeonamesID,					\
							  __dnsfiParamAWKFile, __dnsfiParamErrorStream) {
	# Calculate the primary key
	dnsfPK = getPrimaryKey(__dnsfiParamIataCode, __dnsfiParamLocationType, \
						   __dnsfiParamGeonamesID)

	#
	print ("[" __dnsfiParamAWKFile "] Next step: fix the entry in the ORI " \
		   "file of best known coordinates for the " dnsfPK " primary key")	\
		> __dnsfiParamErrorStream
}


##
# Calculate an alternate location type
function getAltLocTypeFromGeo(__galtfgParamLocationType) {
	if (isLocTypeTvlRtd(__galtfgParamLocationType)) {
		__resultLocationType = "C" __galtfgParamLocationType

	} else if (isLocTypeCity(__galtfgParamLocationType)) {
		__resultLocationType = "O"
	}
	return __resultLocationType
}

##
# Calculate an alternate location type
function areLocTypeSimilarEnough(__altseParamORILocType, \
								 __altseParamGeoLocType) {
	__resultAreSimilar = 0
	if (isLocTypeTvlRtd(__altseParamORILocType)			\
		&& isLocTypeTvlRtd(__altseParamGeoLocType)) {
		__resultAreSimilar = 1
		return __resultAreSimilar
	}

	if ((isLocTypeCity(__altseParamORILocType)		\
		 || match (__altseParamORILocType, "O")) &&	\
		(isLocTypeCity(__altseParamGeoLocType)		\
		 || match (__altseParamGeoLocType, "O"))) {
		__resultAreSimilar = 1
		return __resultAreSimilar
	}

	return __resultAreSimilar
}

##
# Register the full Geonames POR entry details for the given primary key:
# 1. The IATA code
# 2. The ORI-maintained location type
# 3. The ORI-maintained Geonames ID
function registerGeonamesLine(__rglParamIataCode, __rglParamFeatureCode, \
							  __rglParamGeonamesID, __rglParamFullLine,	\
							  __rglParamAWKFile, __rglParamErrorStream,	\
							  __rglParamLogLevel, __rglParamNbOfPOR) {

	# Derive the location type from the feature code.
	# Note: by design of a Geonames POR entry, its location type is individual.
	#       However, the POR entry may have been registered in the ORI list as
	#       combined. In that latter case, a 'C' has to be added in front of
	#       the travel-related location type. For instance, 'A' => 'CA'.
	rglLocationType = getLocationType(__rglParamFeatureCode)

	# Sanity check: the location type should be known
	if (rglLocationType == "NA") {
  		print ("[" __rglParamAWKFile "] !!!! Error at line #" __rglParamNbOfPOR \
			   ", the POR with that IATA code ('" __rglParamIataCode		\
			   "') has an unknown feature code ('" __rglParamFeatureCode	\
			   "') - Full line: " __rglParamFullLine) > __rglParamErrorStream
		return
	}

	# Display the last read POR entry, when:
	# 1. The current POR entry is not the first one (as the last POR entry
	#    then is not defined).
	# 2. The current POR entry has got a (IATA code, location type) combination
	#    distinct from the last POR entry.
	if (__rglParamIataCode == geo_iata_code || __rglParamNbOfPOR == 1) {
		
	} else {
		# Display the last Geonames POR entries
		displayGeonamesPOREntries(__rglParamAWKFile, __rglParamErrorStream,	\
								  __rglParamLogLevel)
	}

	# Register the Geonames POR entry in the list of last entries
	# for that IATA code
	geo_iata_code = __rglParamIataCode

	# DEBUG
	#print ("[" __rglParamAWKFile "][" __rglParamNbOfPOR "] iata_code="	\
	#	   __rglParamIataCode ", feat_code=" __rglParamFeatureCode		\
	#	   ", geo_loc_type=" rglLocationType ", GeoID=" __rglParamGeonamesID) \
	#	> __rglParamErrorStream

	# Add the location type to the dedicated list
	geo_line_loctype_list = addLocTypeToGeoList(rglLocationType, \
												geo_line_loctype_list)

	# Add the Geonames ID to the dedicated list for that location type
	addGeoIDToGeoList(rglLocationType, __rglParamGeonamesID, geo_line_geoid_list)

	# Store the full details of the Geonames POR entry
	geo_line_list[__rglParamGeonamesID] = __rglParamFullLine
}

##
# Display the full details of the Geonames POR entry, prefixed by the
# corresponding primary key (IATA code, location type, Geonames ID).
#
function displayPORWithPK(__dpwpParamIataCode, __dpwpParamORILocType,	\
						  __dpwpParamORIGeoID, __dpwpParamGeonamesGeoID, \
						  __dpwpParamAWKFile, __dpwpParamErrorStream,	\
						  __dpwpParamLogLevel) {
	# Notification
	if (__dpwpParamGeonamesGeoID != __dpwpParamORIGeoID && \
		__dpwpParamLogLevel >= 4) {
		print ("[" __dpwpParamAWKFile "] !!!! Warning at line #" FNR	\
			   ", the POR with that IATA code ('" __dpwpParamIataCode	\
			   "') and location type ('" __dpwpParamORILocType			\
			   "') is referenced in the ORI-maintained list, "			\
			   "but with a different Geonames ID (" __dpwpParamORIGeoID	\
			   ") than the Geonames' one (" __dpwpParamGeonamesGeoID	\
			   "'). The retained Geonames ID is " __dpwpParamORIGeoID)	\
			> __dpwpParamErrorStream
		displayNextStepFixID(__dpwpParamIataCode, __dpwpParamORILocType, \
							 __dpwpParamORIGeoID,						\
							 __dpwpParamAWKFile, __dpwpParamErrorStream)
	}

	# Build the primary key
	dpwpPK = getPrimaryKey(__dpwpParamIataCode, __dpwpParamORILocType, \
						   __dpwpParamORIGeoID)

	# Retrieve the full details of the Geonames POR entry
	dpwpGeonamesPORLine = geo_line_list[__dpwpParamGeonamesGeoID]

	# Add the primary key as a prefix
	dpwpGeonamesPORPlusPKLine = dpwpPK FS dpwpGeonamesPORLine

	# Dump the full line, prefixed by the primary key
	print (dpwpGeonamesPORPlusPKLine)
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
function displayGeonamesPOREntries(__dgpeParamAWKFile, __dgpeParamErrorStream, \
								   __dgpeParamLogLevel) {

	# Calculate the number of the Geonames POR entries corresponding to
	# the last IATA code.
	dgpeNbOfGeoPOR = length(geo_line_list)

	# Browse all the location types known by ORI for that IATA code
	dgpeORILocTypeList = ori_por_loctype_list[geo_iata_code]
	split (dgpeORILocTypeList, dgpeORILocTypeArray, ",")
	for (dgpeORILocTypeIdx in dgpeORILocTypeArray) {
		#
		dgpeORILocType = dgpeORILocTypeArray[dgpeORILocTypeIdx]

		# Browse all the Geonames IDs known by ORI for that (IATA code,
		# location type) combination
		dgpeORIGeoIDList = ori_por_geoid_list[geo_iata_code, dgpeORILocType]
		split (dgpeORIGeoIDList, dgpeORIGeoIDArray, ",")
		for (dgpeORIGeoIDIdx in dgpeORIGeoIDArray) {
			#
			dgpeORIGeoID = dgpeORIGeoIDArray[dgpeORIGeoIDIdx]

			# Check whether the ORI-derived location type is to be found
			# in the Geonames POR entries for that IATA code
			if (dgpeORILocType in geo_line_geoid_list) {
				# Retrieve the list of Geonames ID
				dgpeGeoIDList = geo_line_geoid_list[dgpeORILocType]

				# DEBUG
				#print ("[" __dgpeParamAWKFile "] iata_code=" geo_iata_code	\
				#	   ", ORI-loctype=" dgpeORILocType ", ORI-GeoID="	\
				#	   dgpeORIGeoID ", Geo-GeoIDList=" dgpeGeoIDList)	\
				#	> __dgpeParamErrorStream

				# Extract the first Geonames ID from the Geonames-derived list
				split (dgpeGeoIDList, dgpeGeoIDArray, ",")
				dgpeGeoID = dgpeGeoIDArray[1]

				# Display the full details of the Geonames POR entry
				displayPORWithPK(geo_iata_code, dgpeORILocType, dgpeORIGeoID, \
								 dgpeGeoID)

			} else {
				# The ORI location type is not found in the list of
				# Geonames-derived location types. Typically, The ORI location
				# type may be combined (e.g., 'CA', 'CH', 'CR', 'CB', 'CP')
				# or correspond to an off-line point (i.e., 'O'), while the
				# Geonames-derived location types are individual (i.e., either
				# 'C' or travel-related such 'A', 'H', 'R', 'B', 'P').
				# In all the cases, there is a single location type in ORI
				# and potentially several in Geonames. If they are similar
				# enough, The Geonames-derived location type is replaced by
				# ORI's one.
				dgpeAreSimilar = areLocTypeSimilarEnough(dgpeORILocType, \
														 geo_line_loctype_list)
				if (dgpeAreSimilar) {
					# Extract the first location type from the Geonames-derived
					# list
					split (geo_line_loctype_list, dgpeLocTypeArray, ",")
					dgpeGeoLocType = dgpeLocTypeArray[1]

					# Retrieve the list of Geonames ID
					dgpeGeoIDList = geo_line_geoid_list[dgpeGeoLocType]

					# Extract the first Geonames ID from the Geonames-derived
					# list
					split (dgpeGeoIDList, dgpeGeoIDArray, ",")
					dgpeGeoID = dgpeGeoIDArray[1]

					# Display the full details of the Geonames POR entry
					displayPORWithPK(geo_iata_code, dgpeORILocType, \
									 dgpeORIGeoID, dgpeGeoID)

				} else {
					# Notification
					print ("[" __dgpeParamAWKFile "] iata_code=" geo_iata_code \
						   ", ORI-loctype=" dgpeORILocType ", ORI-GeoID=" \
						   dgpeORIGeoID " not found in Geonames. "		\
						   "Known Geo ID list: "						\
						   geo_line_loctype_list) > __dgpeParamErrorStream
				}
			}
		}
	}

	# Reset the list for the next turn
	resetGeonamesLineList()
}
