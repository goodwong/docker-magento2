FROM docker-magento2-php74-fpm

RUN apt-get update && apt-get install -y cron sudo

# php 内存
RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini \
    && echo "memory_limit = 1024M" >> $PHP_INI_DIR/conf.d/memory_limit.ini

ENTRYPOINT []

CMD sudo -u www-data /var/www/html/bin/magento cron:install --force && cron -f
