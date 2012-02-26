
--
-- Extract airport and city information from the Geonames tables (in particular,
-- geoname and alternate_name)
--

select geonameid, name, latitude, longitude, country, fcode, population,
	   timezone, alternatenames
from geoname
where fcode = 'PPLA'
   or fcode = 'PPLA2'
   or fcode = 'PPLA3'
   or fcode = 'PPLA4'
   or fcode = 'PPLC'
   or fcode = 'PPLG';

-- where fcode = 'PPL';

