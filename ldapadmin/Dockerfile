FROM tomcat:8-jre8

RUN apt-get update && apt-get install -y unzip

RUN rm -rf /usr/local/tomcat/webapps/*
COPY ldapadmin.war /usr/local/tomcat/webapps/ldapadmin.war
RUN chmod a+r /usr/local/tomcat/webapps/*.war

RUN mkdir /tmp/georchestra

EXPOSE 8080

VOLUME  ["/tmp/georchestra","/usr/local/tomcat/logs"]
