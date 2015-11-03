FROM tomcat:8-jre8

RUN echo "deb http://ftp.fr.debian.org/debian jessie contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ jessie/updates contrib non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y unzip libjai-core-java libjai-imageio-core-java ttf-mscorefonts-installer libgdal1h libgdal-java gdal-bin

ADD http://downloads.sourceforge.net/project/libjpeg-turbo/1.4.0/libjpeg-turbo-official_1.4.0_amd64.deb?use_mirror=tenet /tmp/libjpeg-turbo-official_1.4.0_amd64.deb
RUN dpkg -i /tmp/libjpeg-turbo-official_1.4.0_amd64.deb

ADD https://github.com/bourgesl/marlin-renderer/releases/download/v0.4.5/marlin-0.4.5.jar /usr/share/java/marlin.jar

RUN ln -s /usr/share/java/jai_core.jar /usr/local/tomcat/lib/jai_core.jar
RUN ln -s /usr/share/java/jai_codec.jar /usr/local/tomcat/lib/jai_codec.jar
RUN ln -s /usr/share/java/mlibwrapper_jai.jar /usr/local/tomcat/lib/mlibwrapper_jai.jar
RUN ln -s /usr/share/java/jai_imageio.jar /usr/local/tomcat/lib/jai_imageio.jar
RUN ln -s /usr/share/java/clibwrapper_jiio.jar /usr/local/tomcat/lib/clibwrapper_jiio.jar

RUN rm -rf /usr/local/tomcat/webapps/*
COPY geoserver.war /usr/local/tomcat/webapps/geoserver.war
RUN chmod a+r /usr/local/tomcat/webapps/*.war

RUN mkdir -p /usr/local/tomcat/webapps/geoserver && \
    unzip -e /usr/local/tomcat/webapps/geoserver.war -d /usr/local/tomcat/webapps/geoserver

RUN rm -rf /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/imageio-ext-gdal-bindings-*.jar
RUN cp /usr/share/java/gdal.jar /usr/local/tomcat/webapps/geoserver/WEB-INF/lib/gdal.jar

RUN mkdir /tmp/georchestra

EXPOSE 8080

VOLUME  ["/tmp/georchestra","/usr/local/tomcat/logs","/usr/local/tomcat/geoserver_datadir"]
