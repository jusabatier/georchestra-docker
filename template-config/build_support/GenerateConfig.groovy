/*
 * This file can optionally generate configuration files.  The classic example
 * is when a project has both a integration and a production server.
 *
 * The configuration might be in a subdirectory of build_support (which is not copied into the configuration by default)
 * This script can copy the files to the outputDir and copy a shared.maven.filters with the parameters that
 * are needed depending on target and subTarget.  More can be done but that is the classic example
 */
class GenerateConfig {

    def instanceName = "@shared.instance.name@"

    /**
     * @param project The maven project.  you can get all information about
     * the project from this object
     * @param log a logger for logging info
     * @param ant an AntBuilder (see groovy docs) for executing ant tasks
     * @param basedirFile a File object that references the base directory
     * of the conf project
     * @param target the server property which is normally set by the build
     * profile.  It indicates the project that is being built
     * @param subTarget the "subTarget" that the project is being deployed
     * to. For example integration or production
     * @param targetDir a File object referencing the targetDir
     * @param buildSupportDir a File object referencing the build_support
     * dir of the target project
     * @param outputDir the directory to copy the generated configuration
     * files to
     */
    def generate(def project, def log, def ant, def basedirFile,
      def target, def subTarget, def targetDir,
      def buildSupportDir, def outputDir) {

        updateGeoServerProperties()
        updateGeoFenceProperties()
        updateMapfishappMavenFilters()
        updateExtractorappMavenFilters()
        updateSecProxyMavenFilters()
        updateLDAPadminMavenFilters()
    }

    /**
     * updateMapfishappMavenFilters
     */
    def updateMapfishappMavenFilters() {
        new PropertyUpdate(
            path: 'maven.filter',
            from: 'defaults/mapfishapp', 
            to: 'mapfishapp'
        ).update { properties ->
            // this is the directory where older temporary documents are stored:
            properties['docTempDir'] = "/tmp/mapfishapp"
        }
    }


    /**
     * updateGeoServerProperties
     */
    def updateGeoServerProperties() {
        new PropertyUpdate(
            path: 'geofence-geoserver.properties',
            from: 'defaults/geoserver-webapp/WEB-INF/classes',
            to: 'geoserver-webapp/WEB-INF/classes'
        ).update { properties ->
            // if you're running GeoFence, update the following URL to match your setup:
            properties['servicesUrl'] = "http://geofence_host:8080/geofence/remoting/RuleReader"
        }
    }


    /**
     * updateGeoServerProperties
     */
    def updateGeoFenceProperties() {
        new PropertyUpdate(
            path: 'geofence-datasource-ovr.properties',
            from: 'defaults/geofence-webapp/WEB-INF/classes',
            to: 'geofence-webapp/WEB-INF/classes'
        ).update { properties ->
            properties['geofenceGlobalConfiguration.baseLayerURL'] = "@shared.url.scheme@://{{GEORCHESTRA_HOSTNAME}}/geoserver/wms"
            properties['geofenceGlobalConfiguration.baseLayerName'] = "{{GEOFENCE_BASELAYER_NAME}}"
            properties['geofenceGlobalConfiguration.baseLayerTitle'] = "{{GEOFENCE_BASELAYER_TITLE}}"
            properties['geofenceGlobalConfiguration.baseLayerFormat'] = "{{GEOFENCE_BASELAYER_FORMAT}}"
            properties['geofenceGlobalConfiguration.baseLayerStyle'] = "{{GEOFENCE_BASELAYER_STYLE}}"
            properties['geofenceGlobalConfiguration.mapCenterLon'] = "{{GEOFENCE_MAPCENTER_LON}}"
            properties['geofenceGlobalConfiguration.mapCenterLat'] = "{{GEOFENCE_MAPCENTER_LAT}}"
            properties['geofenceGlobalConfiguration.mapZoom'] = "{{GEOFENCE_MAPZOOM}}"
            properties['geofenceGlobalConfiguration.mapMaxResolution'] = "{{GEOFENCE_MAP_MAX_RESOLUTION}}"
            properties['geofenceGlobalConfiguration.mapMaxExtent'] = "{{GEOFENCE_MAP_MAX_EXTENT}}"
            properties['geofenceGlobalConfiguration.mapProjection'] = "{{GEOFENCE_MAP_PROJECTION}}"
        }
    }

    /**
     * updateExtractorappMavenFilters
     */
    def updateExtractorappMavenFilters() {
        new PropertyUpdate(
            path: 'maven.filter',
            from: 'defaults/extractorapp', 
            to: 'extractorapp'
        ).update { properties ->
            properties['maxCoverageExtractionSize'] = "{{EXTRACTOR_MAX_COVERAGE_EXTRACTION_SIZE}}"
            properties['maxExtractions'] = "{{EXTRACTOR_MAX_EXTRACTIONS}}"
            properties['remoteReproject'] = "true"
            properties['useCommandLineGDAL'] = "false"
            properties['extractionFolderPrefix'] = "{{EXTRACTOR_EXTRACTION_FOLDER_PREFIX}}"
            properties['emailfactory'] = "org.georchestra.extractorapp.ws.EmailFactoryDefault"
            properties['emailsubject'] = "["+instanceName+"] {{EXTRACTOR_EMAIL_SUBJECT}}"
        }
    }


    /**
     * updateSecProxyMavenFilters
     */
    def updateSecProxyMavenFilters() {
        // Change the proxy.mapping value below to match your setup !
        new PropertyUpdate(
            path: 'maven.filter',
            from: 'defaults/security-proxy',
            to: 'security-proxy'
        ).update { properties ->
            properties['cas.private.host'] = "cas_host"
            properties['public.ssl'] = "443"
            properties['private.ssl'] = "8080"
            // remove.xforwarded.headers holds a list of servers for which x-forwarded-* headers should be removed:
            // see https://github.com/georchestra/georchestra/issues/782
            properties['remove.xforwarded.headers'] = "<value>.*geo.admin.ch.*</value>"
            // proxy.mapping 
            properties['proxy.mapping'] = """
<entry key="analytics"     value="http://analytics_host:8080/analytics/" />
<entry key="catalogapp"    value="http://catalogapp_host:8080/catalogapp/" />
<entry key="downloadform"  value="http://downloadform_host:8080/downloadform/" />
<entry key="extractorapp"  value="http://extractorapp_host:8080/extractorapp/" />
<entry key="geonetwork"    value="http://geonetwork_host:8080/geonetwork/" />
<entry key="geoserver"     value="http://geoserver_host:8080/geoserver/" />
<entry key="geowebcache"   value="http://geowebcache_host:8080/geowebcache/" />
<entry key="geofence"      value="http://geofence_host:8080/geofence/" />
<entry key="header"        value="http://header_host:8080/header/" />
<entry key="ldapadmin"     value="http://ldapadmin_host:8080/ldapadmin/" />
<entry key="mapfishapp"    value="http://mapfishapp_host:8080/mapfishapp/" />
<entry key="cas"           value="http://cas_host:8080/cas" />
<entry key="kibana"        value="http://kibana_host:5601/" />
<entry key="static"        value="http://header_host:8080/header/" />""".replaceAll("\n|\t","")
            properties['header.mapping'] = """
<entry key="sec-email"     value="mail" />
<entry key="sec-firstname" value="givenName" />
<entry key="sec-lastname"  value="sn" />
<entry key="sec-org"       value="o" />
<entry key="sec-tel"       value="telephoneNumber" />""".replaceAll("\n|\t","")
            // database health check settings:
            // If the HEALTH CHECK feature is activated, the security proxy monitors db connections.
            properties['checkHealth'] = "{{PROXY_CHECKHEALTH}}"
            properties['psql.db'] = "georchestra"
            properties['max.database.connections'] = "170"
        }
    }


    /**
     * updateLDAPadminMavenFilters
     */
    def updateLDAPadminMavenFilters() {
        new PropertyUpdate(
            path: 'maven.filter',
            from: 'defaults/ldapadmin', 
            to: 'ldapadmin'
        ).update { properties ->
            // ReCaptcha keys for your own domain: 
            // (these are the ones for sdi.georchestra.org, they won't work for you !!!)
            properties['privateKey'] = "{{LDAPADMIN_RECAPTCHA_PRIVATE_KEY}}"
            properties['publicKey'] = "{{LDAPADMIN_RECAPTCHA_PUBLIC_KEY}}"
            // Email subjects:
            properties['subject.account.created'] = "["+instanceName+"] {{LDAPADMIN_SUBJECT_ACCOUNT_CREATED}}"
            properties['subject.account.in.process'] = "["+instanceName+"] {{LDAPADMIN_SUBJECT_ACCOUNT_IN_PROGRESS}}"
            properties['subject.requires.moderation'] = "["+instanceName+"] {{LDAPADMIN_SUBJECT_REQUIRES_MODERATION}}"
            properties['subject.change.password'] = "["+instanceName+"] {{LDAPADMIN_SUBJECT_CHANGE_PASSWORD}}"
            // Moderated signup or free account creation ?
            properties['moderatedSignup'] = "{{LDAPADMIN_MODERATED_SIGNUP}}"
            // Delay in days before the tokens are purged from the db:
            properties['delayInDays'] = "1"
            // List of required fields in forms (CSV list) - possible values are:
            // firstName,surname,phone,facsimile,org,title,description,postalAddress
            // Note that email, uid, password and confirmPassword are always required
            properties['requiredFields'] = "{{LDAPADMIN_REQUIRED_FIELDS}}"
        }
    }


}
