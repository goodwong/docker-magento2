FROM docker-magento2-php-fpm

RUN apt-get update && apt-get install -y cron sudo

# USER www-data

ENTRYPOINT []

CMD sudo -u www-data /var/www/html/bin/magento cron:install --force && cron -f