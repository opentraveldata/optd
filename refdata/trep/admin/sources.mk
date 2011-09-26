# Shell script files
db_sh_sources = \
	$(top_srcdir)/db/admin/create_geo_user.sh

ddl_sh_sources = \
	$(top_srcdir)/db/admin/create_and_fill_trep_db.sh \
	$(top_srcdir)/db/admin/drop_tables_from_trep_db.sh

# SQL files
db_sql_sources = \
	$(top_srcdir)/db/admin/create_geo_user.sql \
	$(top_srcdir)/db/admin/create_geo_geonames_db.sql

ddl_sql_sources = \
	$(top_srcdir)/db/admin/create_table_places.sql \
	$(top_srcdir)/db/admin/create_table_airport_popularity.sql

dml_sql_sources = \
	$(top_srcdir)/db/admin/ref_city.csv \
	$(top_srcdir)/db/admin/ref_place_details.csv \
	$(top_srcdir)/db/admin/ref_place_names.csv \
	$(top_srcdir)/db/admin/ref_airport_popularity.csv
