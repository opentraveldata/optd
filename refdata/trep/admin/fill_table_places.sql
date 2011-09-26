--
--
--

--
-- Load the Airport and City geographical details into the MySQL table
--
load data local infile 'ref_place_details.csv' ignore 
into table ref_place_details character set utf8
fields terminated by ',' enclosed by '' escaped by '\\' 
ignore 1 lines;

--
-- Load the Airport and City names into the MySQL table
--
load data local infile 'ref_place_names.csv' ignore 
into table ref_place_names 
fields terminated by ',' enclosed by '' escaped by '\\' 
ignore 1 lines;

