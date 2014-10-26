#!/bin/bash
createdb geodb
createlang -d geodb plpgsql
psql -dgeodb -f /usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql 
psql -dgeodb -f /usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql 
psql -d geodb -f ./sql/create_tables.sql 
