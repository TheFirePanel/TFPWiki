FROM mediawiki:stable-fpm-alpine

# Install packages
RUN apk update && \
    apk add nginx bash && \
    chown -Rf www-data:www-data /var/lib/nginx
COPY config/nginx/* /etc/nginx/

# Install composer
COPY config/composer/* /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install extra extensions
COPY ./config/extension-installer.sh /tmp/extension-installer.sh
RUN chmod +x /tmp/extension-installer.sh && \
    /bin/bash /tmp/extension-installer.sh && \
    rm /tmp/extension-installer.sh

CMD php-fpm -D && \
    nginx -g "daemon off;"
