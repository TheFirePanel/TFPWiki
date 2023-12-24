FROM mediawiki:stable-fpm-alpine

# Install nginx
RUN apk update && \
    apk add nginx && \
    chown -Rf www-data:www-data /var/lib/nginx
COPY config/nginx/* /etc/nginx/

CMD php-fpm -D && nginx -g "daemon off;"
