--
-- ORI-generated list of POR (points of reference, i.e., airports, cities,
-- places, etc.)
-- See http://mediawiki.orinet.nce.amadeus.net/index.php/Airport_ORI
--
-- Sample:
-- CDG^PARIS CDG^PARIS CDG^PARIS/FR:CHARLES DE GAULLE^PAR^Y^^FR^EUROP^ITC2^FR052^49.01278^2.55^838^Y^A
-- => IATA code ^ Ref name ^ Ref name 2 ^ Full name ^ IATA City code ^ \
--    Is it airport flag ^ State code ^ Country code ^ Region code ^ \
--    Pricing zone ^ Time-zone Group ^ Latitude ^ Longitude ^ \
--    Numeric code ^ Is commercial ^ Type
--

LOAD DATA LOCAL INFILE 'ori_por.csv'
REPLACE
INTO TABLE por
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
  (code, ref_name, ref_name2, full_name, city_code, is_airport, 
  state_code, country_code, region_code, pricing_zone, tz_group,
  latitude, longitude, numeric_code, is_commercial, location_type);

