FROM php:7.3-fpm-stretch

# GD
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# others
RUN apt-get update && apt-get install -y \
        libxml2-dev libzip-dev zip libxslt-dev \
    && docker-php-ext-install soap pdo_mysql zip xsl intl bcmath opcache sockets

# sodium
RUN curl -O -C - https://download.libsodium.org/libsodium/releases/libsodium-1.0.18.tar.gz \
    && tar zxf libsodium-1.0.18.tar.gz \
    && cd libsodium-1.0.18 \
    && ./configure \
    && make && make check \
    && make install \
    && docker-php-ext-install sodium
