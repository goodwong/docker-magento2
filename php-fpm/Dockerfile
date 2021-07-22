FROM php:7.4-fpm

# If you're in China, or you need to change sources, will be set CHANGE_SOURCE to true in .env.
# @TODO 这一块还是有问题。。。
#COPY sources.list.cn /etc/apt/
#ENV CHANGE_SOURCE=CN
#RUN if [ ${CHANGE_SOURCE} = CN ]; then \
#        # Change application source from dl-cdn.alpinelinux.org to aliyun source
#        echo "change to Chinese apt source"; \
#        # 备份原文件
#        mv /etc/apt/sources.list /etc/apt/sources.list.origin; \
#        # 修改为阿里云的镜像源
#        cp /etc/apt/sources.list.cn /etc/apt/sources.list \
#    ;fi

# GD
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# others
RUN apt-get update && apt-get install -y \
        libxml2-dev libzip-dev zip libxslt-dev \
    && docker-php-ext-install soap pdo_mysql zip xsl intl bcmath opcache

# sodium
RUN curl -O -C - https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz \
    && tar zxf libsodium-1.0.18.tar.gz \
    && cd libsodium-1.0.18 \
    && ./configure \
    && make && make check \
    && make install \
    && docker-php-ext-install sodium
