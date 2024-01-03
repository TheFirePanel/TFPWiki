FROM mediawiki:stable-fpm-alpine

# Install packages
RUN apk update && \
    apk add nginx \
    bash \
    lua5.1-dev \
    && \
    chown -Rf www-data:www-data /var/lib/nginx
COPY config/nginx/* /etc/nginx/

# Install extra php extensions
RUN apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
	; \
	\
    pecl install luasandbox; \
	docker-php-ext-enable \
		luasandbox \
	; \
    rm -r /tmp/pear; \
    apk del --no-network .build-deps

# Install composer
COPY config/composer/* /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install extra extensions
COPY ./config/extension-installer.sh /tmp/extension-installer.sh
RUN chmod +x /tmp/extension-installer.sh && \
    /bin/bash /tmp/extension-installer.sh && \
    rm /tmp/extension-installer.sh

# Copy public files to root
COPY ./config/public/* /var/www/html

CMD php-fpm -D && \
    nginx -g "daemon off;"
