## db/admin sub-directory
include $(top_srcdir)/Makefile.common
include $(srcdir)/sources.mk

#
datadir = @datadir@
pkgdatadir = $(datadir)/opentrep
dbadminscriptsdir = $(pkgdatadir)/db/mysql/admin_db
ddlscriptsdir = $(pkgdatadir)/db/mysql/create_tables
dmlscriptsdir = $(pkgdatadir)/db/mysql/fill_tables

#
MAINTAINERCLEANFILES = Makefile.in Makefile

#
noinst_DATA = \
	$(db_sh_sources) $(db_sql_sources) \
	$(ddl_sh_sources) $(ddl_sql_sources) \
	$(dml_sql_sources)
EXTRA_DIST = $(noinst_DATA)


# Targets
install-data-local:
	$(mkinstalldirs) $(DESTDIR)$(dbadminscriptsdir); \
	for f in $(db_sql_sources); do \
		$(INSTALL_DATA) $$f $(DESTDIR)$(dbadminscriptsdir); \
	done
	$(mkinstalldirs) $(DESTDIR)$(ddlscriptsdir); \
	for f in $(ddl_sql_sources); do \
		$(INSTALL_DATA) $$f $(DESTDIR)$(ddlscriptsdir); \
	done
	$(mkinstalldirs) $(DESTDIR)$(dmlscriptsdir); \
	for f in $(dml_sql_sources); do \
		$(INSTALL_DATA) $$f $(DESTDIR)$(dmlscriptsdir); \
	done

uninstall-local:
	rm -rf $(DESTDIR)$(ddlscriptsdir) $(DESTDIR)$(dmlscriptsdir)

clean-local:
	rm -rf *.log *.tag

