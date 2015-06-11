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
    - ./logs:/var/log/postgres
    - ./volumes/postgresql_data:/var/lib/postgresql
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
  environment:
    SLAPD_PASSWORD: {{SLAPD_PASSWORD}}
    GEOSERVER_USER_PASS: {{GEOSERVER_USER_PASS}}
    SASL_ENABLED: {{SASL_ENABLED}}
    SASL_REMOTE_LDAP_IP: {{REMOTE_LDAP_IP}}
    SASL_REMOTE_SEARCH_BASE: {{REMOTE_SEARCH_BASE}}
    SASL_REMOTE_FILTER: {{REMOTE_FILTER}}
    SASL_REMOTE_BIND_DN: {{SASL_REMOTE_BIND_DN}}
    SASL_REMOTE_PASSWORD: {{SASL_REMOTE_PASSWORD}}

