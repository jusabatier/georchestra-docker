php:
  build: ./php
  ports:
    - "9000"
  volumes:
    - ./nginx/georchestra-site:/usr/share/nginx/georchestra
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}

nginx:
  build: ./nginx
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./logs:/tmp/nginx_logs
    - ./nginx/georchestra-site:/usr/share/nginx/georchestra
  links:
    - php:php_host
  extra_hosts:
    - {{GEORCHESTRA_HOSTNAME}}:{{GEORCHESTRA_PUBLIC_IP}}
  environment:
    SSL_PASSPHRASE: {{SSL_PASSPHRASE}}
    SSL_COUNTRY: {{SSL_COUNTRY}}
    SSL_STATE: {{SSL_STATE}}
    SSL_LOCALITY: {{SSL_LOCALITY}}
    SSL_ORGANISATION: {{SSL_ORGANISATION}}
    SSL_UNIT: {{SSL_UNIT}}
    GEORCHESTRA_HOSTNAME: {{GEORCHESTRA_HOSTNAME}}
