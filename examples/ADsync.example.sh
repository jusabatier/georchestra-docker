#!/bin/bash

set -ve

IFS=":"

rm -rf temp
mkdir temp

AD_IP="10.1.1.45"
ADROOT="dc=remote_ad,dc=local"
ADUSER="cn=georchestra SIG,cn=Users,$ADROOT"
ADPWD="password"

LOCALROOT="dc=georchestra,dc=org"
LOCALUSER="cn=admin,$LOCALROOT"
LOCALPWD="secret"

TEMP="temp/tmp.ldif"
ADD="temp/add.ldif"
MODIFY="temp/modify.ldif"
GROUPES="temp/groups.ldif"
LSLOCALUSERS="temp/lsusers"
LSGROUPS="temp/lsgroups"

LOCALEXPORT=`ldapsearch -x -D "$LOCALUSER" -w $LOCALPWD -b "ou=users,$LOCALROOT" -LLL employeeType=AD uid`

## Verification des comptes supprimés sur le AD
while read line; do
	while read -r name value; do
		if [ "$name" = "uid" ]; then
			echo ${value//\"/} | tr -d ' ' >> $LSLOCALUSERS
		fi
	done <<< "$line"
done <<< "$LOCALEXPORT"

if [ -f $LSLOCALUSERS ]; then
	while read line; do
		USER=`ldapsearch -H ldap://$AD_IP -b "$ADROOT" -D "$ADUSER" -w $ADPWD -LLL sAMAccountName=$line|grep -v '^#'`
		if [ -z "$USER" ]; then
			echo $line >> deletedusers.log
			ldapdelete -D "$LOCALUSER" -w $LOCALPWD "uid=$line,ou=users,$LOCALROOT"
			
			GROUPEXPORT=`ldapsearch -x -D "$LOCALUSER" -w $LOCALPWD -b "ou=groups,$LOCALROOT" -LLL member="uid=$line,ou=users,$LOCALROOT" dn`
			while read -r name value; do
				if [ "$name" = "dn" ]; then
					echo ${value//\"/} | tr -d ' ' >> $LSGROUPS
				fi
			done <<< "$GROUPEXPORT"
			
			while read group; do
				echo "$group" > $TEMP
				echo "changetype: modify" > $TEMP
				echo "delete: member" > $TEMP
				echo "member: uid=$line,ou=users,$LOCALROOT" > $TEMP
				echo "" > $TEMP
			done < $LSGROUPS
				
			if [ -f $TEMP ]; then
				ldapmodify -D "$LOCALUSER" -w $LOCALPWD -f $TEMP
				rm $TEMP
			fi
		fi
	done < $LSLOCALUSERS
fi

LSBASETOCOPY[0]="OU=GROUP1,DC=remote_ad,DC=local"
LSBASETOCOPY[1]="OU=GROUP2,DC=remote_ad,DC=local"

LSORGANISATION[0]="Organisation 1"
LSORGANISATION[1]="Organisation 2"

EXPORT="temp/export.ldif"

for K in "${!LSBASETOCOPY[@]}"; do

	BASETOCOPY=${LSBASETOCOPY[$K]}
	ORGANISATION=${LSORGANISATION[$K]}

	ldapsearch -x -H ldap://$AD_IP -D "$ADUSER" -w $ADPWD -b "$BASETOCOPY" sAMAccountName cn givenName sn objectClass ou userPrincipalName mail uSNCreated -LLL | perl -MMIME::Base64 -n -00 -e 's/\n //g;s/(?<=:: )(\S+)/decode_base64($1)/eg;print' > $EXPORT
	
	## Recuperation des ajouts et modifications d'utilisateurs sur le AD
	while read line; do
		if [ -z "$line" ]; then
			sAMAccountName=""
			sn=""
			mail=""
			uSNCreated=""
			cn=""
			givenName=""
			
			while read -r name value; do
				if [ "$name" = "sAMAccountName" ]; then
					sAMAccountName=`echo ${value//\"/} | tr -d ' '`
				fi
				if [ "$name" = "mail" ]; then
					mail=`echo ${value//\"/} | tr -d ' '`
				fi
				if [ "$name" = "sn" ]; then
					sn=`echo ${value//\"/} | tr -d ' '`
				fi
				if [ "$name" = "uSNCreated" ]; then
					uSNCreated=`echo ${value//\"/} | tr -d ' '`
				fi
				if [ "$name" = "cn" ]; then
					cn=`echo ${value//\"/} | tr -d ' '`
				fi
				if [ "$name" = "givenName" ]; then
					givenName=`echo ${value//\"/} | tr -d ' '`
				fi
			done < $TEMP
			
			if [ ! -z "$sAMAccountName" ] && [ ! -z "$sn" ] && [ ! -z "$uSNCreated" ] && [ ! -z "$cn" ] && [ ! -z "$givenName" ]; then
				alreadyExist=`ldapsearch -b $LOCALROOT uid=$sAMAccountName -D "$LOCALUSER" -w $LOCALPWD -LLL`
				
				if [ -z "$alreadyExist" ]; then
					echo "dn: uid=$sAMAccountName,ou=users,$LOCALROOT" >> $ADD
					echo "objectClass: organizationalPerson" >> $ADD
					echo "objectClass: person" >> $ADD
					echo "objectClass: inetOrgPerson" >> $ADD
					echo "objectClass: top" >> $ADD
					if [ ! -z "$mail" ]; then
						echo "mail: $mail" >> $ADD
					else
						echo "mail: $sAMAccountName@agglo-lepuyenvelay.fr" >> $ADD
					fi
					echo "uid: $sAMAccountName" >> $ADD
					echo "sn: $sn" >> $ADD
					echo "userPassword: {SASL}$sAMAccountName@lepuy.local" >> $ADD
					echo "cn: $cn" >> $ADD
					echo "givenName: $givenName" >> $ADD
					
					ENexists=`ldapsearch -b $LOCALROOT employeeNumber=$uSNCreated -D "$LOCALUSER" -w $LOCALPWD -LLL`
					while [ ! -z "$ENexists" ]; do
						uSNCreated=$uSNCreated+1
						ENexists=`ldapsearch -b $LOCALROOT employeeNumber=$uSNCreated -D "$LOCALUSER" -w $LOCALPWD -LLL`
					done
					echo "employeeNumber: $uSNCreated" >> $ADD
					
					echo "employeeType: AD" >> $ADD
					echo "o: $ORGANISATION" >> $ADD
					echo "" >> $ADD
					
					echo "dn: cn=SV_USER,ou=groups,$LOCALROOT" >> $GROUPES
					echo "changetype: modify" >> $GROUPES
					echo "add: member" >> $GROUPES
					echo "member: uid=$sAMAccountName,ou=users,$LOCALROOT" >> $GROUPES
					echo "" >> $GROUPES
				else
					echo "dn: uid=$sAMAccountName,ou=users,$LOCALROOT" >> $MODIFY
					echo "changetype: modify" >> $MODIFY
					echo "replace: mail" >> $MODIFY
					if [ ! -z "$mail" ]; then
						echo "mail: $mail" >> $MODIFY
					else
						echo "mail: $sAMAccountName@agglo-lepuyenvelay.fr" >> $MODIFY
					fi
					echo "-" >> $MODIFY
					echo "replace: sn" >> $MODIFY
					echo "sn: $sn" >> $MODIFY
					echo "-" >> $MODIFY
					echo "replace: cn" >> $MODIFY
					echo "cn: $cn" >> $MODIFY
					echo "-" >> $MODIFY
					echo "replace: givenName" >> $MODIFY
					echo "givenName: $givenName" >> $MODIFY
					echo "" >> $MODIFY
				fi
			fi
			
			rm $TEMP
		fi
		echo "$line" >> $TEMP; 
	done < $EXPORT

	if [ -f $ADD ]; then
		ldapadd -D "$LOCALUSER" -w $LOCALPWD -f $ADD
	fi
	if [ -f $GROUPES ]; then
		ldapmodify -D "$LOCALUSER" -w $LOCALPWD -f $GROUPES
	fi
	if [ -f $MODIFY ]; then
		ldapmodify -D "$LOCALUSER" -w $LOCALPWD -f $MODIFY
	fi

	rm -rf temp/*
done

rm -rf temp

echo "last run : `TZ=Europe/Paris date`" >> lastrun.log
