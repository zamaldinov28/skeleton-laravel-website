FROM php:8.2.3-fpm-alpine

ARG PROJECT_CODE
ENV PROJECT_CODE $PROJECT_CODE
ARG UID
ENV UID $UID
ARG GID
ENV GID $GID

USER root
WORKDIR /var/www/${PROJECT_CODE}

RUN apk add --update --no-cache shadow

RUN groupmod -g "${GID}" www-data
RUN usermod -u "${UID}" www-data

ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive

RUN apk -U upgrade
RUN update-ca-certificates
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apk add --update --no-cache \
    bash \
    bzip2 \
    ca-certificates \
    curl \
    curl-dev \
    dpkg \
    dpkg-dev \
    file  \
    freetype \
    freetype-dev \
    gcc g++ make autoconf \
    gettext \
    git \
    gmp-dev \
    icu-dev \
    jpeg-dev \
    jq \
    ldb-dev  \
    libc-dev \
    libevent-dev \
    libffi-dev \
    libgcc \
    libjpeg \
    libjpeg-turbo \
    libjpeg-turbo-dev  \
    libldap \
    libmcrypt-dev \
    libpng-dev \
    libtool \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    llvm \
    mc \
    nano \
    net-tools \
    nodejs \
    npm \
    oniguruma-dev \
    openjpeg-dev \
    openldap-dev  \
    openssh-client \
    openssl \
    openssl-dev \
    pcre-dev \
    pkgconf \
    re2c  \
    tar \
    tidyhtml-dev \
    tiff-dev \
    tzdata \
    util-linux-dev \
    wget \
    xdg-utils \
    xz \
    zip \
    zlib

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install -j$(nproc) gd && docker-php-ext-enable gd
RUN docker-php-ext-install mbstring && docker-php-ext-enable mbstring
RUN docker-php-ext-install bcmath && docker-php-ext-enable bcmath
RUN docker-php-ext-install zip && docker-php-ext-enable zip
RUN docker-php-ext-install intl && docker-php-ext-enable intl
RUN docker-php-ext-install zip && docker-php-ext-enable zip
RUN docker-php-ext-install exif && docker-php-ext-enable exif
RUN docker-php-ext-install gmp && docker-php-ext-enable gmp
RUN docker-php-ext-install phar && docker-php-ext-enable phar
RUN docker-php-ext-install simplexml && docker-php-ext-enable simplexml
RUN docker-php-ext-install xsl && docker-php-ext-enable xsl
RUN docker-php-ext-install sockets && docker-php-ext-enable sockets
RUN docker-php-ext-install tidy && docker-php-ext-enable tidy
RUN docker-php-ext-install opcache && docker-php-ext-enable opcache
RUN docker-php-ext-install calendar && docker-php-ext-enable calendar
RUN docker-php-ext-install ctype && docker-php-ext-enable ctype
RUN docker-php-ext-install curl && docker-php-ext-enable curl
RUN docker-php-ext-install pdo && docker-php-ext-enable pdo
RUN docker-php-ext-install pdo_mysql && docker-php-ext-enable pdo_mysql
RUN docker-php-ext-install xml && docker-php-ext-enable xml
RUN docker-php-ext-install soap && docker-php-ext-enable soap
RUN docker-php-ext-install pcntl && docker-php-ext-enable pcntl

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN apk add --update --no-cache yaml-dev
RUN pecl install yaml && docker-php-ext-enable yaml

## Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# cron
RUN apk add --update --no-cache busybox-suid
COPY ./cron /etc/cron.d/www-data
RUN chmod -R 0777 /etc/cron.d
RUN echo "" > /var/log/cron.log && echo "" > /var/log/crond.log && chmod 777 /var/log/cron.log && chmod 777 /var/log/crond.log

# supervisor
RUN apk add supervisor
RUN echo "" > /var/log/supervisord.log && chmod 777 /var/log/supervisord.log
RUN mkdir /var/log/supervisor

# SSL for https
RUN curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
RUN chmod +x mkcert-v*-linux-amd64
RUN mv mkcert-v*-linux-amd64 /usr/bin/mkcert
RUN mkcert -install

ENV DEBIAN_FRONTEND=dialog

RUN rm -rf /var/cache/apk/*
RUN rm -rf /tmp/*

VOLUME /var/www/${PROJECT_CODE}
WORKDIR /var/www/${PROJECT_CODE}
