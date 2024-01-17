# Use php-fpm image
FROM mediawiki:stable-fpm

# Install packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx \
    bash \
    curl \
    lua5.1-dev \
    supervisor \
    && \
    chown -Rf www-data:www-data /var/lib/nginx

# Install extra php extensions
RUN pecl install luasandbox; \
	docker-php-ext-enable \
		luasandbox \
	; \
    rm -r /tmp/pear

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Run extension installer
COPY scripts /scripts
RUN chmod -R +x /scripts/; \
    /bin/bash /scripts/extension-installer.sh && \
    rm /scripts/extension-installer.sh

# Copy all configuration values to their respective directories
COPY config /

CMD ["/scripts/entrypoint.sh"]