php:
  build: ./php
  ports:
    - "9000"
  volumes:
    - ./nginx/georchestra-site:/usr/share/nginx/georchestra
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

nginx:
  build: ./nginx
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./logs:/tmp/nginx_logs
    - ./nginx/georchestra-site:/usr/share/nginx/georchestra
  links:
    - php:php_host
    - proxy:proxy_host
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}
  environment:
    SSL_PASSPHRASE: {{SSL_PASSPHRASE}}
    SSL_COUNTRY: {{SSL_COUNTRY}}
    SSL_STATE: {{SSL_STATE}}
    SSL_LOCALITY: {{SSL_LOCALITY}}
    SSL_ORGANISATION: {{SSL_ORGANISATION}}
    SSL_UNIT: {{SSL_UNIT}}
    GEORCHESTRA_HOSTNAME: {{GEORCHESTRA_HOSTNAME}}

database:
  build: ./postgresql
  ports:
    - "5432:5432"
  volumes:
    - ./logs:/var/log/postgresql
    - ./volumes/postgresql_data:/var/lib/postgresql
    - ./postgresql/import:/tmp/import-pgsql
  environment:
    DB_MAIN_USER: {{DB_MAIN_USER}}
    DB_MAIN_USER_PASS: {{DB_MAIN_USER_PASS}}
    DB_GEORCHESTRA_PASS: {{DB_GEORCHESTRA_PASS}}
    DB_GEONETWORK_PASS: {{DB_GEONETWORK_PASS}}
    GEORCHESTRA_HOSTNAME: {{GEORCHESTRA_HOSTNAME}}
    GEOSERVER_USER_PASS: {{GEOSERVER_USER_PASS}}

ldap:
  build: ./ldap
  ports:
    - "389:389"
  volumes:
    - ./logs:/var/log/ldap
    - ./volumes/ldap_data/slapd.d:/etc/ldap/slapd.d
    - ./volumes/ldap_data/lib:/var/lib/ldap
    - ./ldap/cron.weekly:/etc/cron.weekly
    - ./ldap/import:/tmp/ldap-import
  environment:
    SLAPD_PASSWORD: {{SLAPD_PASSWORD}}
    GEOSERVER_USER_PASS: {{GEOSERVER_USER_PASS}}
    SASL_ENABLED: {{SASL_ENABLED}}
    SASL_REMOTE_LDAP_IP: {{SASL_REMOTE_LDAP_IP}}
    SASL_REMOTE_SEARCH_BASE: {{SASL_REMOTE_SEARCH_BASE}}
    SASL_REMOTE_FILTER: {{SASL_REMOTE_FILTER}}
    SASL_REMOTE_BIND_DN: {{SASL_REMOTE_BIND_DN}}
    SASL_REMOTE_PASSWORD: {{SASL_REMOTE_PASSWORD}}

proxy:
  build: ./proxy
  privileged: true
  ports:
    - "8080:8080"
  links:
    - database:database_host
    - ldap:ldap_host
    - cas:cas_host
    - header:header_host
    - geonetwork:geonetwork_host
    - mapfishapp:mapfishapp_host
    - analytics:analytics_host
    - catalogapp:catalogapp_host
    - downloadform:downloadform_host
    - extractorapp:extractorapp_host
    - ldapadmin:ldapadmin_host
    - geoserver:geoserver_host
    - geofence:geofence_host
    - geowebcache:geowebcache_host
    - elk:elk_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/proxy:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms512m -Xmx512m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}
    - proxy_host:127.0.0.1

cas:
  build: ./cas
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
    - ldap:ldap_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/cas:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms512m -Xmx512m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}
    - cas_host:127.0.0.1

header:
  build: ./header
  privileged: true
  ports:
    - "8080"
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/header:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms256m -Xmx256m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

geonetwork:
  build: ./geonetwork
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
    - ldap:ldap_host
    - cas:cas_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/geonetwork:/usr/local/tomcat/logs
    - ./volumes/geonetwork_datadir:/usr/local/tomcat/geonetwork_datadir
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms2G -Xmx2G -Dgeonetwork.dir=/usr/local/tomcat/geonetwork_datadir -Dgeonetwork.schema.dir=/usr/local/tomcat/geonetwork_datadir/config/schema_plugins -Dgeonetwork.jeeves.configuration.overrides.file=/usr/local/tomcat/webapps/geonetwork/WEB-INF/config-overrides-georchestra.xml -Djava.util.prefs.userRoot=/tmp/georchestra -Djava.util.prefs.systemRoot=/tmp/georchestra"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

mapfishapp:
  build: ./mapfishapp
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/mapfishapp:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms2G -Xmx2G"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

analytics:
  build: ./analytics
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/analytics:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms256m -Xmx256m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

catalogapp:
  build: ./catalogapp
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/catalogapp:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms256m -Xmx256m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

downloadform:
  build: ./downloadform
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/downloadform:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms256m -Xmx256m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

extractorapp:
  build: ./extractorapp
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/extractorapp:/usr/local/tomcat/logs
    - ./volumes/extractor_tmpdir:/usr/local/tomcat/extractor_tmpdir
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms2G -Xmx2G -Dorg.geotools.referencing.forceXY=true -Dextractor.storage.dir=/usr/local/tomcat/extractor_tmpdir -Djava.util.prefs.userRoot=/tmp/georchestra -Djava.util.prefs.systemRoot=/tmp/georchestra"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

ldapadmin:
  build: ./ldapadmin
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
    - ldap:ldap_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/ldapadmin:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms256m -Xmx256m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

geofence:
  build: ./geofence
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
    - ldap:ldap_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/geofence:/usr/local/tomcat/logs
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms512m -Xmx512m"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

geoserver:
  build: ./geoserver
  privileged: true
  ports:
    - "8080"
  links:
    - database:database_host
    - geofence:geofence_host
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/geoserver:/usr/local/tomcat/logs
    - ./volumes/geoserver_datadir:/usr/local/tomcat/geoserver_datadir
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms2G -Xmx2G -XX:PermSize=256m -DGEOSERVER_DATA_DIR=/usr/local/tomcat/geoserver_datadir -Dfile.encoding=UTF8 -Djavax.servlet.request.encoding=UTF-8 -Djavax.servlet.response.encoding=UTF-8 -server -XX:+UseParNewGC -XX:ParallelGCThreads=2 -XX:SoftRefLRUPolicyMSPerMB=36000 -XX:NewRatio=2 -XX:+AggressiveOpts -Djava.library.path=/usr/lib/jni:/opt/libjpeg-turbo/lib64"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

geowebcache:
  build: ./geowebcache
  privileged: true
  ports:
    - "8080"
  volumes:
    - ./logs:/tmp/georchestra
    - ./logs/tomcat/geowebcache:/usr/local/tomcat/logs
    - ./volumes/geowebcache_cachedir:/usr/local/tomcat/geowebcache_cachedir
  environment:
    JAVA_OPTS: "-Djava.awt.headless=true -XX:+UseConcMarkSweepGC -Xms1G -Xmx1G -XX:PermSize=256m -Djava.library.path=/usr/lib/jni -DGEOWEBCACHE_CACHE_DIR=/usr/local/tomcat/geowebcache_cachedir"
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

elk:
  build: ./elk
  privileged: true
  ports:
    - "5601"
    - "9200"
    - "5000"
  volumes:
    - ./elk/logstash/conf.d:/etc/logstash/conf.d
    - ./elk/ssl:/etc/pki/tls/certs
  environment:
    SSL_PASSPHRASE: {{SSL_PASSPHRASE}}
    SSL_COUNTRY: {{SSL_COUNTRY}}
    SSL_STATE: {{SSL_STATE}}
    SSL_LOCALITY: {{SSL_LOCALITY}}
    SSL_ORGANISATION: {{SSL_ORGANISATION}}
    SSL_UNIT: {{SSL_UNIT}}
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

elkclient:
  build: ./elkclient
  privileged: true
  links:
    - elk:elk_host
  volumes:
    - ./logs:/var/log/georchestra-docker
    - ./elk/ssl:/etc/pki/tls/certs
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}
