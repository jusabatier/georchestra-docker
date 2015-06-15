FROM tomcat:7-jre8

RUN apt-get update && apt-get install -y unzip

RUN rm -rf /usr/local/tomcat/webapps/*
COPY analytics.war /usr/local/tomcat/webapps/analytics.war
RUN chmod a+r /usr/local/tomcat/webapps/*.war

RUN mkdir /tmp/georchestra

EXPOSE 8080

VOLUME  ["/tmp/georchestra","/usr/local/tomcat/logs"]
