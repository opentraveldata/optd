--
-- Place details
-- Does not depend on language
--
create table if not exists ref_place_details (
  code char(3) collate utf8_unicode_ci not null,
  city_code char(3) collate utf8_unicode_ci,
  xapian_docid integer,
  is_airport char(1) collate utf8_unicode_ci not null,
  is_city char(1) collate utf8_unicode_ci not null,
  is_main char(1) collate utf8_unicode_ci not null default 'N',
  is_commercial char(1) collate utf8_unicode_ci not null,
  state_code varchar(5) collate utf8_unicode_ci,
  country_code char(2) collate utf8_unicode_ci not null,
  region_code varchar(5) collate utf8_unicode_ci not null,
  continent_code varchar(4) collate utf8_unicode_ci not null,
  time_zone_grp varchar(5) collate utf8_unicode_ci not null,
  longitude float(20),
  latitude float(20),
  primary key (code),
  key `geographical codes`(city_code, continent_code, country_code, region_code, time_zone_grp)
) engine=myisam default charset=utf8 collate=utf8_unicode_ci;

--
-- Place names
-- Depends on language
--
create table if not exists ref_place_names (
  language_code char(2) collate utf8_unicode_ci not null,
  code char(3) collate utf8_unicode_ci not null,
  classical_name varchar(30) collate utf8_unicode_ci not null,
  extended_name varchar(100) collate utf8_unicode_ci not null,
  alternate_name1 varchar(60) collate utf8_unicode_ci,
  alternate_name2 varchar(60) collate utf8_unicode_ci,
  alternate_name3 varchar(60) collate utf8_unicode_ci,
  alternate_name4 varchar(60) collate utf8_unicode_ci,
  alternate_name5 varchar(60) collate utf8_unicode_ci,
  alternate_name6 varchar(60) collate utf8_unicode_ci,
  alternate_name7 varchar(60) collate utf8_unicode_ci,
  alternate_name8 varchar(60) collate utf8_unicode_ci,
  alternate_name9 varchar(60) collate utf8_unicode_ci,
  alternate_name10 varchar(60) collate utf8_unicode_ci,
  primary key (language_code, code)
) engine=myisam default charset=utf8 collate=utf8_unicode_ci;

