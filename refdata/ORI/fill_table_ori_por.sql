--
-- ORI-maintained list of POR (points of reference, i.e., airports, cities,
-- places, etc.)
-- See https://github.com/opentraveldata/optd/tree/trunk/refdata/ORI
--
--

LOAD DATA LOCAL INFILE 'ori_por.csv'
REPLACE
INTO TABLE por
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
  (iata_code, icao_code, is_geonames, geonameid, name, asciiname,
   alternatenames, latitude, longitude, fclass, fcode, 
   country_code, cc2, admin1, admin2, admin3, admin4, 
   population, elevation, gtopo30, timezone, moddate,
   is_airport, is_commercial,
   city_code, state_code, region_code, location_type);
