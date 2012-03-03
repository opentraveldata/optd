--
-- ORI-generated list of airports/cities/places
-- See http://mediawiki.orinet.nce.amadeus.net/index.php/Airport_ORI
--
-- Sample:
-- CDG^PARIS CDG^PARIS CDG^PARIS/FR:CHARLES DE GAULLE^PAR^Y^^FR^EUROP^ITC2^FR052^2.55^49.01278^838^Y^A
-- => IATA code ^ Ref name ^ Ref name 2 ^ Full name ^ IATA City code ^ \
--    Is it airport flag ^ State code ^ Country code ^ Region code ^ \
--    Pricing zone ^ Time-zone Group ^ Longitude ^ Latitude ^ \
--    Numeric code ^ Is commercial ^ Type
--

LOAD DATA LOCAL INFILE 'additionalCodes.txt'
REPLACE
INTO TABLE ori_cities
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
  (ref_name, location_type, ref_name2, full_name, city_code, is_airport, 
  state_code, country_code, region_code, pricing_zone, tz_group,
  longitude, latitude, numeric_code, is_commercial, code);
