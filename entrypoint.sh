#!/bin/sh
if [[ -f "/usr/sbin/php-fpm7" ]]; then
    php-fpm7 -v
    php-fpm7 -D
fi

exec caddy run $@
