
--
-- Extract information from the Geonames tables (in particular, geoname and
-- alternate_name), for all the points of reference (POR, i.e., mainly
-- airports/airbases/heliports and cities).
--
-- Two intermediary tables are generated, namely iata_codes and icao_codes,
-- which contain the geoname ID, code type (IATA, resp. ICAO) and
-- IATA (resp. ICAO) code.
-- Those two temporary tables are then joined with the 'geoname' table,
-- which contains all the details for those given points of reference (POR).
--
-- It may appear not so simple to have such an intermediary step. That is
-- because some airports/heliports do not have IATA and/or ICAO code at all.
-- For those cases, the corresponding field will be NULL in the output (stdout).
--

select iata_codes.alternateName, icao_codes.alternateName, g.geonameid, g.name,
	   g.latitude, g.longitude, g.country, g.fcode, g.population, g.timezone,
	   g.alternatenames
from geoname as g

left join (
select g1.geonameid, a1.isoLanguage, a1.alternateName
from geoname as g1 
left join alternate_name as a1 on g1.geonameid = a1.geonameid
where (g1.fcode = 'AIRP' or g1.fcode = 'AIRH' or g1.fcode = 'AIRB'
	  or g1.fcode = 'PPLA' or g1.fcode = 'PPLA2' or g1.fcode = 'PPLA3'
	  or g1.fcode = 'PPLA4' or g1.fcode = 'PPLC' or g1.fcode = 'PPLG')
  and a1.isoLanguage = 'iata'
order by g1.geonameid
) as iata_codes on g.geonameid = iata_codes.geonameid

left join (
select g2.geonameid, a2.isoLanguage, a2.alternateName 
from geoname as g2 
left join alternate_name as a2 on g2.geonameid = a2.geonameid
where (g2.fcode = 'AIRP' or g2.fcode = 'AIRH' or g2.fcode = 'AIRB'
	  or g2.fcode = 'PPLA' or g2.fcode = 'PPLA2' or g2.fcode = 'PPLA3'
	  or g2.fcode = 'PPLA4' or g2.fcode = 'PPLC' or g2.fcode = 'PPLG')
  and a2.isoLanguage = 'icao'
order by g2.geonameid
) as icao_codes on g.geonameid = icao_codes.geonameid

where (g.fcode = 'AIRP' or g.fcode = 'AIRH' or g.fcode = 'AIRB'
	  or g.fcode = 'PPLA' or g.fcode = 'PPLA2' or g.fcode = 'PPLA3'
	  or g.fcode = 'PPLA4' or g.fcode = 'PPLC' or g.fcode = 'PPLG')

order by iata_codes.alternateName, icao_codes.alternateName, g.fcode
;
