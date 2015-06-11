FROM nginx

ADD ./default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

VOLUME ["/tmp","/usr/share/nginx/georchestra"]

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
