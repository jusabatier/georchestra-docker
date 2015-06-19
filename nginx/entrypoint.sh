#!/bin/bash

set -e

if [[ ! -f /usr/share/nginx/georchestra/ssl/georchestra.chained.crt || ! -f /usr/share/nginx/georchestra/ssl/georchestra.key ]]; then
	rm -rf /usr/share/nginx/georchestra/ssl/*
	
	openssl genrsa -des3 -passout pass:$SSL_PASSPHRASE -out /usr/share/nginx/georchestra/ssl/georchestra-protected.key 2048
	openssl req -key /usr/share/nginx/georchestra/ssl/georchestra-protected.key -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCALITY/O=$SSL_ORGANISATION/OU=$SSL_UNIT/CN=$GEORCHESTRA_HOSTNAME" -newkey rsa:2048 -sha256 -out /usr/share/nginx/georchestra/ssl/georchestra.csr -passin pass:$SSL_PASSPHRASE
	openssl rsa -in /usr/share/nginx/georchestra/ssl/georchestra-protected.key -out /usr/share/nginx/georchestra/ssl/georchestra.key -passin pass:$SSL_PASSPHRASE
	openssl x509 -req -days 365 -in /usr/share/nginx/georchestra/ssl/georchestra.csr -signkey /usr/share/nginx/georchestra/ssl/georchestra-protected.key -out /usr/share/nginx/georchestra/ssl/georchestra.chained.crt -passin pass:$SSL_PASSPHRASE
	
	chmod 777 /usr/share/nginx/georchestra/ssl/georchestra.key
	chmod 777 /usr/share/nginx/georchestra/ssl/georchestra.chained.crt
	rm /usr/share/nginx/georchestra/ssl/georchestra.csr /usr/share/nginx/georchestra/ssl/georchestra-protected.key
fi

sed -i "s/example.georchestra-docker.fr/$GEORCHESTRA_HOSTNAME/g" /etc/nginx/conf.d/default.conf

exec "$@"
