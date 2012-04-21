--
-- ORI-generated list of airport importance data
--

LOAD DATA LOCAL INFILE 'ref_airport_pageranked.csv'
REPLACE
INTO TABLE airport_pageranked
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
 (iata_code, page_rank);

