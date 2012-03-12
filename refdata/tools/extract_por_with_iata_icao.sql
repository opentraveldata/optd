
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

select iata_codes.alternateName as iata, icao_codes.alternateName as icao,
	   g.geonameid, g.name, g.asciiname, g.latitude, g.longitude,
	   g.country, g.cc2, g.fclass, g.fcode,
	   g.admin1, g.admin2, g.admin3, g.admin4,
	   g.population, g.elevation, g.gtopo30,
	   g.timezone, tz.GMT_offset, tz.DST_offset, tz.raw_offset,
	   g.moddate, g.alternatenames
from time_zones as tz, geoname as g

left join (
select g1.geonameid, a1.isoLanguage, a1.alternateName
from geoname as g1 
left join alternate_name as a1 on g1.geonameid = a1.geonameid
where (g1.fcode = 'AIRP' or g1.fcode = 'AIRH' or g1.fcode = 'AIRB'
	  or g1.fcode = 'RSTN'
	  or g1.fcode = 'PPLA' or g1.fcode = 'PPLA2' or g1.fcode = 'PPLA3'
	  or g1.fcode = 'PPLA4' or g1.fcode = 'PPLC' or g1.fcode = 'PPLG')
  and a1.isoLanguage = 'iata'
order by g1.geonameid
) as iata_codes on iata_codes.geonameid = g.geonameid

left join (
select g2.geonameid, a2.isoLanguage, a2.alternateName 
from geoname as g2 
left join alternate_name as a2 on g2.geonameid = a2.geonameid
where (g2.fcode = 'AIRP' or g2.fcode = 'AIRH' or g2.fcode = 'AIRB'
	  or g2.fcode = 'RSTN'
	  or g2.fcode = 'PPLA' or g2.fcode = 'PPLA2' or g2.fcode = 'PPLA3'
	  or g2.fcode = 'PPLA4' or g2.fcode = 'PPLC' or g2.fcode = 'PPLG')
  and a2.isoLanguage = 'icao'
order by g2.geonameid
) as icao_codes on icao_codes.geonameid = g.geonameid

where (g.fcode = 'AIRP' or g.fcode = 'AIRH' or g.fcode = 'AIRB'
	  or g.fcode = 'RSTN'
	  or g.fcode = 'PPLA' or g.fcode = 'PPLA2' or g.fcode = 'PPLA3'
	  or g.fcode = 'PPLA4' or g.fcode = 'PPLC' or g.fcode = 'PPLG')
	  and g.timezone = tz.timeZoneId

order by iata_codes.alternateName, icao_codes.alternateName, g.fcode
;
