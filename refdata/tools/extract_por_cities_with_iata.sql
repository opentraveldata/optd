
--
-- Extract information from the Geonames tables (in particular, geoname and
-- alternate_name), for all the populated places (i.e., cities) and
-- administrative divisions (e.g., municipalities) having got a IATA code
-- (e.g., 'LON' for London, UK, 'PAR' for Paris, France and
-- 'SFO' for San Francisco, CA, USA).
--

select a.alternateName as iata, 'NULL',
	   g.geonameid, g.name, g.asciiname, g.latitude, g.longitude,
	   g.country, g.cc2, g.fclass, g.fcode,
	   g.admin1, g.admin2, g.admin3, g.admin4,
	   g.population, g.elevation, g.gtopo30,
	   g.timezone, tz.GMT_offset, tz.DST_offset, tz.raw_offset,
	   g.moddate, g.alternatenames
from time_zones as tz, geoname as g
left join alternate_name as a on g.geonameid = a.geonameid
where (g.fcode like 'PPL%' or g.fcode like 'ADM%')
	  and a.isoLanguage = 'iata'
	  and a.isHistoric = 0
	  and g.timezone = tz.timeZoneId
order by a.alternateName, g.fcode
;
