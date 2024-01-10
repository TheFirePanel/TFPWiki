FROM mediawiki:stable-fpm-alpine

# Install packages
RUN apk update && \
    apk add nginx \
    bash \
    curl \
    lua5.1-dev \
    supervisor \
    && \
    chown -Rf www-data:www-data /var/lib/nginx

COPY config/nginx/* /etc/nginx/
COPY config/supervisor /etc/supervisor/

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

# Install scripts and run extension installer
COPY ./config/scripts/ /scripts/
RUN chmod -R +x /scripts/; \
    /bin/bash /scripts/extension-installer.sh && \
    rm /scripts/extension-installer.sh

# Copy public files to root
COPY ./config/public/* /var/www/html

CMD ["/scripts/entrypoint.sh"]
