FROM tomcat:7-jre8

RUN apt-get update && apt-get install -y unzip

RUN rm -rf /usr/local/tomcat/webapps/*
COPY cas.war /usr/local/tomcat/webapps/cas.war
RUN chmod a+r /usr/local/tomcat/webapps/*.war

RUN mkdir /tmp/georchestra

COPY server.xml /usr/local/tomcat/conf/server.xml

EXPOSE 8080

VOLUME  ["/tmp/georchestra","/usr/local/tomcat/logs"]
