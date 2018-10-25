FROM docker-magento2-php-fpm

# copied from official composer Dockerfile
RUN curl -s -f -L -o /tmp/installer.php https://install.phpcomposer.com/installer \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer \
    && composer --ansi --version --no-interaction \
    && rm -rf /tmp/* /tmp/.htaccess

RUN if [ ${CHANGE_SOURCE} = 'CN' ]; then \
    # Change composer to china source \
    echo "change to Chinese composer source"; \
    composer config -g repo.packagist composer https://packagist.phpcomposer.com \
;fi

USER www-data

ENTRYPOINT []

CMD ["/bin/bash"]