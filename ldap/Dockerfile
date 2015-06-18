FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y slapd ldap-utils logrotate sasl2-bin

ADD https://raw.githubusercontent.com/georchestra/LDAP/master/georchestra-bootstrap.ldif /tmp/georchestra-bootstrap.ldif
ADD https://raw.githubusercontent.com/georchestra/LDAP/master/georchestra-memberof.ldif /tmp/georchestra-memberof.ldif
ADD https://raw.githubusercontent.com/georchestra/LDAP/master/georchestra-root.ldif /tmp/georchestra-root.ldif
ADD https://raw.githubusercontent.com/georchestra/LDAP/master/georchestra.ldif /tmp/georchestra.ldif

EXPOSE 389

VOLUME  ["/var/log/ldap", "/etc/ldap/slapd.d","/var/lib/ldap","/etc/cron.weekly","/tmp/ldap-import"]

COPY logrotate /etc/logrotate.d/openldap
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD /usr/sbin/slapd -h "ldap:/// ldapi:///" -g openldap -u openldap -F /etc/ldap/slapd.d -d 256
