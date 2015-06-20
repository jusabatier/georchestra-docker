#!/bin/bash

set -e

openssl genrsa -des3 -passout pass:$SSL_PASSPHRASE -out /tmp/elk-protected.key 2048
openssl req -key /tmp/elk-protected.key -subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCALITY/O=$SSL_ORGANISATION/OU=$SSL_UNIT/CN=elk_host" -newkey rsa:2048 -sha256 -out /tmp/elk.csr -passin pass:$SSL_PASSPHRASE
openssl rsa -in /tmp/elk-protected.key -out /tmp/elk.key -passin pass:$SSL_PASSPHRASE
openssl x509 -req -days 365 -in /tmp/elk.csr -signkey /tmp/elk-protected.key -out /tmp/elk.chained.crt -passin pass:$SSL_PASSPHRASE

mv /tmp/elk.chained.crt /etc/pki/tls/certs/elk.chained.crt
mv /tmp/elk.key /etc/pki/tls/private/elk.key

chmod 777 /etc/pki/tls/certs/elk.chained.crt
chmod 777 /etc/pki/tls/private/elk.key

rm /tmp/elk.csr /tmp/elk-protected.key

exec "$@"
