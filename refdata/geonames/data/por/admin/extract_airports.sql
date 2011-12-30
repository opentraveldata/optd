
--
-- Extract airport and city information from the Geonames tables (in particular,
-- geoname and alternate_name)
--

select a1.alternateName, a2.alternateName, g.geonameid, g.name,
	   g.latitude, g.longitude, g.country, g.fcode, g.population, g.timezone,
	   g.alternatenames
from geoname as g 
left join alternate_name as a1 on g.geonameid = a1.geonameid
left join alternate_name as a2 on a1.geonameid = a2.geonameid
where g.fcode = 'AIRP'
  and a1.isoLanguage = 'iata'
  and a2.isoLanguage = 'icao';
