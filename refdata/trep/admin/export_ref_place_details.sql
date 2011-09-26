--
-- Export data from the ref_place_details table
--
select concat_ws(',', code, city_code, xapian_docid, is_airport, is_city,
	   is_main, is_commercial, state_code, country_code, region_code,
	   continent_code, time_zone_grp, longitude, latitude)
from ref_place_details;

