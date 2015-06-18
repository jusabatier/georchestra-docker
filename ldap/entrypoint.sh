#!/bin/bash

set -e

if [ "$(ls -A /var/lib/ldap)" == ".gitignore" ] || [ -z "$(ls -A /var/lib/ldap)" ]; then
	cat <<-EOF | debconf-set-selections
	slapd slapd/internal/generated_adminpw password $SLAPD_PASSWORD
	slapd slapd/internal/adminpw password $SLAPD_PASSWORD
	slapd slapd/password1 password $SLAPD_PASSWORD
	slapd slapd/password2 password $SLAPD_PASSWORD
	slapd slapd/purge_database boolean true
	slapd slapd/backend select MDB
	slapd slapd/move_old_database boolean true
	slapd slapd/no_configuration boolean false
	slapd slapd/dump_database select when needed
EOF

	dpkg-reconfigure -f noninteractive slapd

	if [ -f /etc/ldap/slapd.d/cn\=config/olcDatabase\=\{1\}mdb.ldif ] ; then
		rm /etc/ldap/slapd.d/cn\=config/olcDatabase\=\{1\}mdb.ldif
	fi

	sed -i -e "s/secret/$SLAPD_PASSWORD/g" /tmp/georchestra-bootstrap.ldif
	
	/etc/init.d/slapd start
	ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/georchestra-bootstrap.ldif
	ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/georchestra-memberof.ldif
	
	if [ -f /tmp/ldap-import/import.ldif ]; then
		kill -INT `cat /run/slapd/slapd.pid`
		slapadd -b "dc=georchestra,dc=org" -q -l /tmp/ldap-import/import.ldif
		/etc/init.d/slapd start
	else
		ldapadd -D "cn=admin,dc=georchestra,dc=org" -w $SLAPD_PASSWORD -f /tmp/georchestra-root.ldif
		ldapadd -D "cn=admin,dc=georchestra,dc=org" -w $SLAPD_PASSWORD -f /tmp/georchestra.ldif
	fi
	
	ldappasswd -s $GEOSERVER_USER_PASS -w $SLAPD_PASSWORD -D "cn=admin,dc=georchestra,dc=org" -x "uid=geoserver_privileged_user,ou=users,dc=georchestra,dc=org"
	
	kill -INT `cat /run/slapd/slapd.pid`
fi

if [[ $SASL_ENABLED == "true" && ! -f /etc/ldap/sasl2/slapd.conf ]]; then
		/etc/init.d/slapd start
		sed -i -e "s/START=no/START=yes/g" /etc/default/saslauthd
		sed -i -e "s/MECHANISMS=\"pam\"/MECHANISMS=\"ldap\"/g" /etc/default/saslauthd
		
		echo "ldap_servers: ldap://$SASL_REMOTE_LDAP_IP" > /etc/saslauthd.conf
		echo "ldap_search_base: $SASL_REMOTE_SEARCH_BASE" >> /etc/saslauthd.conf
		echo "ldap_timeout: 10" >> /etc/saslauthd.conf
		echo "ldap_filter: $SASL_REMOTE_FILTER" >> /etc/saslauthd.conf
		echo "ldap_bind_dn: $SASL_REMOTE_BIND_DN" >> /etc/saslauthd.conf
		echo "ldap_password: $SASL_REMOTE_PASSWORD" >> /etc/saslauthd.conf
		echo "ldap_deref: never" >> /etc/saslauthd.conf
		echo "ldap_restart: yes" >> /etc/saslauthd.conf
		echo "ldap_scope: sub" >> /etc/saslauthd.conf
		echo "ldap_use_sasl: no" >> /etc/saslauthd.conf
		echo "ldap_start_tls: no" >> /etc/saslauthd.conf
		echo "ldap_version: 3" >> /etc/saslauthd.conf
		echo "ldap_auth_method: bind" >> /etc/saslauthd.conf
		
		SASLHOST_VALUE=`ldapsearch -Q -Y EXTERNAL -H ldapi:/// -LLL -b "cn=config" -s base -A olcSaslHost | grep olcSaslHost`
		
		if [ -z $SASLHOST_VALUE ]; then
			ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: cn=config
changetype: modify
add: olcSaslHost
olcSaslHost: localhost
EOF
		fi

		SASLSECPROPS_VALUE=`ldapsearch -Q -Y EXTERNAL -H ldapi:/// -LLL -b "cn=config" -s base -A olcSaslSecProps | grep olcSaslSecProps`
		
		if [ -z $SASLSECPROPS_VALUE ]; then
			ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: cn=config
changetype:modify
add: olcSaslSecProps
olcSaslSecProps: none
EOF
		fi

		echo "pwcheck_method: saslauthd" > /etc/ldap/sasl2/slapd.conf
		echo "saslauthd_path: /var/run/saslauthd/mux" >> /etc/ldap/sasl2/slapd.conf
		
		adduser openldap sasl
		kill -INT `cat /run/slapd/slapd.pid`
fi

if [ ! -f /etc/rsyslog.conf ]; then
	echo "local4.* /var/log/ldap/ldap.log" >> /etc/rsyslog.conf
fi

if [[ ! -f /etc/cron.weekly/lastrun.log && ! -z "$(ls -A /etc/cron.weekly)" ]]; then
	/etc/init.d/slapd start
	run-parts /etc/cron.weekly
	kill -INT `cat /run/slapd/slapd.pid`
fi

if [ $SASL_ENABLED == "true" ]; then
	/etc/init.d/saslauthd start
fi

exec "$@"

