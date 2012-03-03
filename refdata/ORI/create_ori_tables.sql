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
-- Note: the index is created in a separate file, namely create_ori_indexes.sql
--
--
drop table if exists por;
create table por (
 code VARCHAR(3) NOT NULL,
 ref_name varchar(20) NOT NULL,
 ref_name2 varchar(20) NOT NULL,
 full_name varchar(50) NOT NULL,
 city_code varchar(3) NOT NULL,
 is_airport varchar(1) NOT NULL,
 state_code varchar(3),
 country_code varchar(2) NOT NULL,
 region_code varchar(5) NOT NULL,
 pricing_zone varchar(4),
 tz_group varchar(5) NOT NULL,
 latitude float(20),
 longitude float(20),
 numeric_code decimal,
 is_commercial varchar(1) NOT NULL,
 location_type varchar(4)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

