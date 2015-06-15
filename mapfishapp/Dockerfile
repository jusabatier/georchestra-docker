FROM tomcat:7-jre8

RUN apt-get update && apt-get install -y unzip libgdal1h libgdal-java

RUN rm -rf /usr/local/tomcat/webapps/*
COPY mapfishapp.war /usr/local/tomcat/webapps/mapfishapp.war
RUN chmod a+r /usr/local/tomcat/webapps/*.war

RUN mkdir -p /usr/local/tomcat/webapps/mapfishapp && \
	unzip -e /usr/local/tomcat/webapps/mapfishapp.war -d /usr/local/tomcat/webapps/mapfishapp

RUN rm -rf /usr/local/tomcat/webapps/mapfishapp/WEB-INF/lib/imageio-ext-gdalframework-*.jar
RUN cp /usr/share/java/gdal.jar /usr/local/tomcat/webapps/mapfishapp/WEB-INF/lib/gdal.jar

RUN mkdir /tmp/georchestra

EXPOSE 8080

VOLUME  ["/tmp/georchestra","/usr/local/tomcat/logs"]
