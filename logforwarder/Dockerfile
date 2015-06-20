FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y install wget

RUN echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | tee /etc/apt/sources.list.d/logstashforwarder.list
RUN wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN apt-get update && apt-get install -y logstash-forwarder

RUN mkdir -p /etc/pki/tls/certs

COPY ./logstash-forwarder.conf /etc/logstash-forwarder.conf

VOLUME  ["/var/log/georchestra-docker","/etc/pki/tls/certs"]

CMD sleep 600 && service logstash-forwarder start && tail -F /var/log/logstash-forwarder/logstash-forwarder.err
