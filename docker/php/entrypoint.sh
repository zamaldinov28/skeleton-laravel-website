#!/bin/bash

crond -c /etc/cron.d -L /var/log/crond.log

supervisord -c /etc/supervisord.conf

[ ! -f /var/www/${PROJECT_CODE}/docker/nginx/${PROJECT_CODE}.pem ] && \
	mkcert -cert-file /var/www/${PROJECT_CODE}/docker/nginx/certs/${PROJECT_CODE}.pem -key-file /var/www/${PROJECT_CODE}/docker/nginx/certs/${PROJECT_CODE}-key.pem "${PROJECT_CODE}.local" && \
	mkcert -cert-file /var/www/${PROJECT_CODE}/docker/nginx/certs/_wildcard.${PROJECT_CODE}.pem -key-file /var/www/${PROJECT_CODE}/docker/nginx/certs/_wildcard.${PROJECT_CODE}-key.pem "*.${PROJECT_CODE}.local" && \
	chmod 777 -R /var/www/${PROJECT_CODE}/docker/nginx/certs

su -s /bin/bash www-data

php /var/www/${PROJECT_CODE}/artisan profiler:server > /var/log/profiler_server.log 2>&1 &
php /var/www/${PROJECT_CODE}/artisan profiler:client > /var/log/profiler_client.log 2>&1 &

php-fpm

$@
