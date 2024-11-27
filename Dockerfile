#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
FROM php:8.3-fpm

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
            curl \
            libmemcached-dev \
            libz-dev \
            libpq-dev \
            libjpeg-dev \
            libpng-dev \
            libfreetype6-dev \
            libssl-dev \
            libwebp-dev \
            libxpm-dev \
            libmcrypt-dev \
            libonig-dev \
            zlib1g-dev \
            libzip-dev \
            tzdata; \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf /usr/share/zoneinfo/Europe/Vienna /etc/localtime && \
    echo "Europe/Vienna" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

RUN set -eux; \
    # Install PHP extensions
    docker-php-ext-install pdo_mysql pdo_pgsql zip; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp; \
    docker-php-ext-install gd;

# Install Node.js 18.x (optional, for frontend builds or npm commands)
RUN apt-get update && apt-get install -y nodejs npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get latest Composer
COPY --from=composer:2.5.8 /usr/bin/composer /usr/bin/composer

# Create a non-root user
ARG user=laravel
ARG uid=1000
RUN useradd -G www-data,root -u $uid -d /home/$user $user && mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user
