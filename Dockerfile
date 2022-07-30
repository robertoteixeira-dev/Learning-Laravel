# Arguments defined in docker-compose.yml
ARG user
ARG uid
FROM php:8.1.0-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 123 -d /home/rangel rangel
RUN mkdir -p /home/rangel/.composer && \
    chown -R rangel:rangel /home/rangel

# Install redis
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Set working directory
WORKDIR /var/www

COPY ./ /var/www/

RUN ls

#RUN composer update
RUN rm -rf vendor composer.lock && composer install

USER rangel

EXPOSE 8000
