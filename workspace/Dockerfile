FROM docker-magento2-php-fpm

# copied from official composer Dockerfile
# magento 要求 composer 1.x
RUN curl -s -f -L -o /tmp/installer.php https://getcomposer.org/installer \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=1.10.6 \
    && composer --ansi --version --no-interaction \
    && rm -rf /tmp/* /tmp/.htaccess

# # Install MariaDB client
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get install -y mariadb-client \ 
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# 安装 git开发工具
RUN apt-get update && apt-get install -y git

# php 内存
RUN cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini \
    && echo "memory_limit = 4096M" >> $PHP_INI_DIR/conf.d/memory_limit.ini

# www-data的home目录权限有问题，所以需要自行创建并添加权限
RUN mkdir -p /var/www/.composer/ \
    && chown -R www-data:www-data /var/www/
USER www-data

# 将magento加入命令列表
ENV PATH=$PATH:/var/www/html/bin

ENTRYPOINT []
CMD ["/bin/bash"]