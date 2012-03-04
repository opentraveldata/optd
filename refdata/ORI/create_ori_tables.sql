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


--
-- Table structure for the table storing airport popularity details
--
drop table if exists airport_popularity;
create table airport_popularity (
  region_code char(3) NOT NULL,
  country varchar(20) NOT NULL,
  city varchar(40) NOT NULL,
  airport varchar(40) NOT NULL,
  airport_code char(3) NOT NULL,
  atmsa int(8) NULL,
  atmsb int(8) NULL,
  atmsc int(8) NULL,
  atmsd int(8) NULL,
  tatm int(8) NULL,
  paxa int(8) NULL,
  paxb int(8) NULL,
  paxc int(8) NULL,
  paxd int(8) NULL,
  tpax int(8) NULL,
  frta int(8) NULL,
  frtb int(8) NULL,
  tfrt int(8) NULL,
  mail int(8) NULL,
  tcgo int(8) NULL,
  latmsa int(8) NULL,
  latmsb int(8) NULL,
  latmsc int(8) NULL,
  latmsd int(8) NULL,
  ltatm int(8) NULL,
  lpaxa int(8) NULL,
  lpaxb int(8) NULL,
  lpaxc int(8) NULL,
  lpaxd int(8) NULL,
  ltpax int(8) NULL,
  lfrta int(8) NULL,
  lfrtb int(8) NULL,
  ltfrt int(8) NULL,
  lmail int(8) NULL,
  ltcgo int(8) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

