--
--
--
-- select concat_ws(', ', code, city_code, is_airport, state_code, country_code,
-- region_code, continent_code, time_zone_grp, longitude, latitude)
-- from geo_geonames.ref_city;

--
-- Airports
-- select concat_ws(', ', CODE,REL_CITY_CODE, STATE_CODE, REL_COUNTRY_CODE, REL_REGION_CODE, REL_CONTINENT_CODE, REL_TIME_ZONE_GRP, LONGITUDE, LATITUDE, IS_COMMERCIAL) 
-- from geo_rfd.CRB_CITY_ORIGIN
-- where IS_AIRPORT = 'Y';

--
-- Airports and cities
--
select concat(CODE, ',,,', IS_AIRPORT, ',Y,N,', IS_COMMERCIAL, ','), trim(STATE_CODE), concat(',', REL_COUNTRY_CODE, ',', REL_REGION_CODE, ',', REL_CONTINENT_CODE, ',', REL_TIME_ZONE_GRP, ','), LONGITUDE, ',', LATITUDE, ','
from geo_rfd.CRB_CITY_ORIGIN
where CODE = REL_CITY_CODE
union
select concat(CODE, ',', REL_CITY_CODE, ',,', IS_AIRPORT, ',N,N,', IS_COMMERCIAL, ','), trim(STATE_CODE), concat(',', REL_COUNTRY_CODE, ',', REL_REGION_CODE, ',', REL_CONTINENT_CODE, ',', REL_TIME_ZONE_GRP, ','), LONGITUDE, ',', LATITUDE, ','
from geo_rfd.CRB_CITY_ORIGIN
where CODE != REL_CITY_CODE;

-- select concat('en,', CODE, ',', TICKETING_NAME, ',', TELETICKETING_NAME, ',', EXTENDED_NAME)
-- from geo_rfd.CRB_CITY_ORIGIN

-- select concat(CODE,TICKETING_NAME,TELETICKETING_NAME,EXTENDED_NAME,CITY_NAME,REL_CITY_CODE,IS_AIRPORT,STATE_CODE,REL_COUNTRY_CODE,REL_REGION_CODE,REL_CONTINENT_CODE,REL_TIME_ZONE_GRP,LONGITUDE,LATITUDE,NUMERIC_CODE,IS_COMMERCIAL)
-- from CRB_CITY_ORIGIN;

