FROM php:8.3-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev libzip-dev libicu-dev unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql mysqli gd zip intl bcmath exif opcache \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

# mod_php needs prefork only
RUN rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.* \
    && a2enmod mpm_prefork

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Serve Laravel from public/ (public/index.php sets DOMAIN_POINTED_DIRECTORY = 'public')
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri 's!AllowOverride None!AllowOverride All!g' /etc/apache2/apache2.conf \
    && printf "upload_max_filesize=50M\npost_max_size=50M\nmemory_limit=512M\nmax_execution_time=120\n" > /usr/local/etc/php/conf.d/app.ini

WORKDIR /var/www/html

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction

COPY . .
RUN composer dump-autoload --optimize --no-dev \
    && chmod +x docker/entrypoint.sh \
    && chown -R www-data:www-data storage bootstrap/cache resources/lang

CMD ["docker/entrypoint.sh"]
