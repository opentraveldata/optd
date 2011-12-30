-- MySQL dump 10.11
--
-- Host: localhost    Database: geonames
-- ------------------------------------------------------
-- Server version	5.5.18


--
-- Index structure for table `admin1_codes_ascii`
--

ALTER TABLE `admin1_codes_ascii` ADD PRIMARY KEY (`geonameid`);
ALTER TABLE `admin1_codes_ascii` ADD UNIQUE (`code`);


--
-- Index structure for table `admin2_codes`
--

ALTER TABLE `admin2_codes` ADD PRIMARY KEY (`geonameid`);


--
-- Index structure for table `alternate_name`
--
ALTER TABLE `alternate_name` ADD PRIMARY KEY (`alternatenameId`);
ALTER TABLE `alternate_name` ADD INDEX (`geonameid`);


--
-- Index structure for table `continent_codes`
--

ALTER TABLE `continent_codes` ADD PRIMARY KEY (`code`);


--
-- Index structure for table `country_info`
--
DELETE FROM `country_info` WHERE `iso_alpha2` = 'iso';

ALTER TABLE `country_info` ADD PRIMARY KEY (`iso_alpha2`);
ALTER TABLE `country_info` ADD UNIQUE (`iso_alpha3`);
ALTER TABLE `country_info` ADD UNIQUE (`iso_numeric`);
ALTER TABLE `country_info` ADD INDEX (`fips_code`);
ALTER TABLE `country_info` ADD UNIQUE (`name`);
ALTER TABLE `country_info` ADD INDEX (`geonameId`);


--
-- Index structure for table `feature_codes`
--

ALTER TABLE `feature_codes` ADD PRIMARY KEY (`code`);


--
-- Index structure for table `geoname`
--

ALTER TABLE `geoname` ADD PRIMARY KEY (`geonameid`);
ALTER TABLE `geoname` ADD INDEX (`fcode`);


--
-- Index structure for table `iso_language_codes`
--
DELETE FROM `iso_language_codes` WHERE `iso_639_3` = 'iso';

ALTER TABLE `iso_language_codes` ADD PRIMARY KEY (`iso_639_3`);


--
-- Index structure for table `time_zones`
--

ALTER TABLE `time_zones` ADD PRIMARY KEY (`timeZoneId`);


--
-- Index structure for table `hierarchy`
--

ALTER TABLE `hierarchy` ADD PRIMARY KEY (`parentId`, `childId`);


-- Dump completed on 2011-12-29  0:52:34
