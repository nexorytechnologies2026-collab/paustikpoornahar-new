#!/bin/sh
set -e
cd /var/www/html

# mod_php needs prefork; a second MPM makes Apache refuse to start
rm -f /etc/apache2/mods-enabled/mpm_event.* /etc/apache2/mods-enabled/mpm_worker.*
a2enmod mpm_prefork >/dev/null 2>&1 || true

# Railway injects PORT; Apache listens on 80 by default
PORT="${PORT:-8080}"
sed -ri "s/^Listen [0-9]+/Listen ${PORT}/" /etc/apache2/ports.conf
sed -ri "s/<VirtualHost \*:[0-9]+>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

mkdir -p storage/app/public storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache

# First boot: import seed database, create admin, seed default images (all no-ops once done)
php docker/railway-init.php

php artisan storage:link --force >/dev/null 2>&1 || true
php artisan view:cache >/dev/null 2>&1 || true

chown -R www-data:www-data storage bootstrap/cache

exec apache2-foreground
