FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get -y install php5-fpm
RUN sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 9000/' /etc/php5/fpm/pool.d/www.conf

EXPOSE 9000

VOLUME ["/usr/share/nginx/georchestra"]

CMD ["/usr/sbin/php5-fpm", "-F"]
