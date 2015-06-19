# How to do several treatments with this Docker instance

## Import an LDAP directory

If you already have a Georchestra instance, you should want to import your current LDAP directory (users and groups).

For that, we assume that your LDAP tree is under : **dc=georchestra,dc=org**, and the administrator is **cn=admin,dc=georchestra,dc=org** like in the Georchestra default config.

In order to do that, on your current LDAP server, generate the export file : 

```
slapcat -b "dc=georchestra,dc=org" > import.ldif
```

Then put the _import.ldif_ file generated in the **ldap/import** folder.

After that ensure that LDAP is not yet configured in your persistent volume (This will delete current container's LDAP directory) : 

```
sudo rm -rf volumes/ldap_data/lib/* volumes/ldap_data/slapd.d/*
```

Your LDAP directory will be imported at next container's launch.

> Note : the user with DN _uid=geoserver_privileged_user,ou=users,dc=georchestra,dc=org_ will be updated with the password set in configuration.txt



## Import Postgres/PostGIS databases

If you have already a Georchestra database configured or other databases to import, you should want to import them.

### Georchestra database import

On your current database host : 

```
su postgres
pg_dump --no-acl --no-owner -E utf8 georchestra > import-georchestra.sql
```

Then put the _import-georchestra.sql_ file generated in the **postgresql/import** folder.

After that ensure that Postgres/PostGIS is not yet configured in your persistent volume (This will delete current container's Postgres/PostGIS databases) : 

```
sudo rm -rf volumes/postgresql_data/*
```

Your Georchestra database will be imported at next container's launch.

> Note : during the import, the owners of database, schema and tables will be reconfigured to match with georchestra and geonetwork users and the main user set in configuration.txt will be granted as database administrator. Moreover, geofence's geoserver instance with name _default-gs_ will be updated with the geoserver_privileged_user's password set in configuration.txt

### Import other databases

On your current database host : 

```
su postgres
pg_dump --no-acl --no-owner -E utf8 -C datasig > import-datasig.sql
```

Then put the _import-datasig.sql_ file generated in the **postgresql/import** folder.

After that ensure that Postgres/PostGIS is not yet configured in your persistent volume (This will delete current container's Postgres/PostGIS databases) : 

```
sudo rm -rf volumes/postgresql_data/*
```

Your Georchestra database will be imported at next container's launch.

> Note : You can put as *.sql files as you want in **postgresql/import** folder, it will be scanned and each **.sql** files will be imported in database, just keep in mind that the _import-georchestra.sql_ is reserved for the georchestra database import file.
