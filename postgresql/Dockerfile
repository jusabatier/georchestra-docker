FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y install postgresql-9.4-postgis-2.1 sudo

ADD https://raw.github.com/georchestra/georchestra/master/mapfishapp/database.sql /tmp/mapfishapp.sql
ADD https://raw.github.com/georchestra/georchestra/master/ldapadmin/database.sql /tmp/ldapadmin.sql
ADD https://raw.github.com/georchestra/geofence/georchestra-14.12/doc/setup/sql/002_create_schema_postgres.sql /tmp/geofence.sql
ADD https://raw.github.com/georchestra/georchestra/master/downloadform/database.sql /tmp/downloadform.sql
ADD https://raw.github.com/georchestra/georchestra/master/ogc-server-statistics/database.sql /tmp/ogcstatistics.sql
RUN chmod a+r /tmp/*.sql

RUN sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.4/main/postgresql.conf
RUN sed -i 's/shared_buffers = 128MB/shared_buffers = 1024MB/' /etc/postgresql/9.4/main/postgresql.conf

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.4/main/pg_hba.conf

RUN mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp
RUN chown postgres /var/run/postgresql/9.4-main.pg_stat_tmp
RUN chgrp postgres /var/run/postgresql/9.4-main.pg_stat_tmp

RUN sed -i "s/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g" /etc/locale.gen
RUN /usr/sbin/locale-gen
RUN export LANG=fr_FR.UTF-8

USER postgres

EXPOSE 5432

VOLUME  ["/var/log/postgresql", "/var/lib/postgresql","/tmp/import-pgsql"]

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/lib/postgresql/9.4/bin/postgres", "-D", "/var/lib/postgresql/9.4/main", "-c", "config_file=/etc/postgresql/9.4/main/postgresql.conf"]
