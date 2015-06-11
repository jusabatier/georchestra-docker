#!/bin/bash

set -e

if [ ! -d /var/lib/postgresql/9.4/main ]; then
	/usr/lib/postgresql/9.4/bin/initdb --pgdata "/var/lib/postgresql/9.4/main" --username=postgres --encoding=utf8 --auth=trust >/dev/null
fi

if [[ ! -f /var/lib/postgresql/docker-configured ]]; then
	/etc/init.d/postgresql start
	psql -c "CREATE USER \"$DB_MAIN_USER\" WITH SUPERUSER PASSWORD '$DB_MAIN_USER_PASS';"
	createdb -E UTF8 -T template0 -U postgres template_postgis
	psql -d template_postgis -f /usr/share/postgresql/9.4/contrib/postgis-2.1/postgis.sql
	psql -d template_postgis -f /usr/share/postgresql/9.4/contrib/postgis-2.1/postgis_comments.sql
	psql -d template_postgis -f /usr/share/postgresql/9.4/contrib/postgis-2.1/spatial_ref_sys.sql
	createdb -E UTF8 -T template_postgis georchestra
	psql -d georchestra -c "CREATE USER \"georchestra\" WITH PASSWORD '$DB_GEORCHESTRA_PASS';"
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON DATABASE georchestra TO "georchestra";'
	psql -d georchestra -c "CREATE USER geonetwork WITH PASSWORD '$DB_GEONETWORK_PASS';"
	psql -d georchestra -c 'CREATE SCHEMA geonetwork;'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON SCHEMA geonetwork TO "geonetwork";'
	psql -d georchestra -f /tmp/mapfishapp.sql
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON SCHEMA mapfishapp TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA mapfishapp TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA mapfishapp TO "georchestra";'
	psql -d georchestra -f /tmp/ldapadmin.sql
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON SCHEMA ldapadmin TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ldapadmin TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ldapadmin TO "georchestra";'
	psql -d georchestra -c 'GRANT SELECT ON public.spatial_ref_sys to "georchestra";'
	psql -d georchestra -c 'GRANT SELECT,INSERT,DELETE ON public.geometry_columns to "georchestra";'
	psql -d georchestra -f /tmp/geofence.sql
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON SCHEMA geofence TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA geofence TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA geofence TO "georchestra";'
	psql -d georchestra -c "INSERT INTO geofence.gf_gsinstance (id, baseURL, dateCreation, description, name, password, username) values (0, 'https://$GEORCHESTRA_HOSTNAME/geoserver', 'now', 'local geoserver', 'default-gs', '$GEOSERVER_USER_PASS', 'geoserver_privileged_user');"
	psql -d georchestra -f /tmp/downloadform.sql
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON SCHEMA downloadform TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA downloadform TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA downloadform TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON SCHEMA downloadform TO "geonetwork";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA downloadform TO "geonetwork";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA downloadform TO "geonetwork";'
	psql -d georchestra -f /tmp/ogcstatistics.sql
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON SCHEMA ogcstatistics TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ogcstatistics TO "georchestra";'
	psql -d georchestra -c 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ogcstatistics TO "georchestra";'
	/etc/init.d/postgresql stop
	
	date +%s > /var/lib/postgresql/docker-configured
fi

exec "$@"
