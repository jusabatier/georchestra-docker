FROM tomcat:8-jre8

RUN echo "deb http://ftp.fr.debian.org/debian jessie contrib non-free" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ jessie/updates contrib non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y unzip libjai-core-java libjai-imageio-core-java

RUN ln -s /usr/share/java/jai_core.jar /usr/local/tomcat/lib/jai_core.jar
RUN ln -s /usr/share/java/jai_codec.jar /usr/local/tomcat/lib/jai_codec.jar
RUN ln -s /usr/share/java/mlibwrapper_jai.jar /usr/local/tomcat/lib/mlibwrapper_jai.jar
RUN ln -s /usr/share/java/jai_imageio.jar /usr/local/tomcat/lib/jai_imageio.jar
RUN ln -s /usr/share/java/clibwrapper_jiio.jar /usr/local/tomcat/lib/clibwrapper_jiio.jar

RUN rm -rf /usr/local/tomcat/webapps/*
COPY geowebcache.war /usr/local/tomcat/webapps/geowebcache.war
RUN chmod a+r /usr/local/tomcat/webapps/*.war

RUN mkdir /tmp/georchestra

EXPOSE 8080

VOLUME  ["/tmp/georchestra","/usr/local/tomcat/logs","/usr/local/tomcat/geowebcache_cachedir"]
