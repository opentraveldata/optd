--
-- Load airport popularity data into the tables of the geo_geonames database
--
--
load data local infile 'ref_airport_popularity.csv' ignore
into table airport_popularity character set utf8
fields terminated by ',' optionally enclosed by '"' escaped by '\\'
ignore 1 lines
(`region_code`, `country`, `city`, `airport`, `airport_code`, 
 `atmsa`, `atmsb`, `atmsc`, `atmsd`, `tatm`, 
 `paxa`, `paxb`, `paxc`, `paxd`, `tpax`, 
 `frta`, `frtb`, `tfrt`, `mail`, `tcgo`, 
 `latmsa`, `latmsb`, `latmsc`, `latmsd`, `ltatm`, 
 `lpaxa`, `lpaxb`, `lpaxc`, `lpaxd`, `ltpax`, 
 `lfrta`, `lfrtb`, `ltfrt`, `lmail`, `ltcgo`)
;
