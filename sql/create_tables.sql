CREATE sequence poi_id_seq;
CREATE sequence city_id_seq;
CREATE sequence region_id_seq;
CREATE sequence country_id_seq;
CREATE sequence continent_id_seq;

CREATE TABLE POI ( 
    id integer PRIMARY KEY DEFAULT NEXTVAL('poi_id_seq'),
    type VARCHAR(70),
    graphid VARCHAR(70) NOT NULL );
SELECT AddGeometryColumn('poi', 'place', 32661, 'POINT', 2);

CREATE INDEX pois_gist ON poi USING gist (place);


--CREATE TABLE city (
--    id INTEGER PRIMARY KEY DEFAULT NEXTVAL('city_id_seq'),
--    name VARCHAR(100)
--);
--SELECT AddGeometryColumn('city', 'polygon', -1, 'POLYGON', 2);

--CREATE TABLE region (
--    id INTEGER PRIMARY KEY DEFAULT NEXTVAL('region_id_seq'),
--    name VARCHAR(100)
--);
--SELECT AddGeometryColumn('region', 'polygon', -1, 'POLYGON', 2);

--CREATE TABLE country (
--    id INTEGER PRIMARY KEY DEFAULT NEXTVAL('country_id_seq'),
--    name VARCHAR(100)
--);
--SELECT AddGeometryColumn('country', 'polygon', -1, 'POLYGON', 2);

--CREATE TABLE continent (
--    id INTEGER PRIMARY KEY DEFAULT NEXTVAL('continent_id_seq'),
--    name VARCHAR(100)
--);
--SELECT AddGeometryColumn('continent', 'polygon', -1, 'POLYGON', 2);
