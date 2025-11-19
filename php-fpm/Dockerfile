FROM php:8.2-fpm

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
        libxml2-dev libzip-dev zip libxslt-dev libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install soap pdo_mysql zip xsl intl bcmath opcache sockets

# sodium
RUN apt-get update && apt-get install -y \
    libsodium-dev \
    && docker-php-ext-install sodium
