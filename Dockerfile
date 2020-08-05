FROM php:7.4-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    git \
    nano \
    libicu-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libxml2-dev

# Clear cache after update and upgrades
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache configs + document root.
RUN echo "ServerName laravel-app.local" >> /etc/apache2/apache2.conf

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Initial PHP configurations, then add extensions.
COPY docker/ezysupport/php.ini "$PHP_INI_DIR/php.ini"

# mod_rewrite for URL rewrite and mod_headers for .htaccess extra headers like Access-Control-Allow-Origin-
RUN a2enmod rewrite headers

# Install others PHP important extensions.
RUN docker-php-ext-install \
    intl \
    iconv \
    bcmath \
    opcache \
    pdo \
    pdo_mysql \ 
    zip \
    json \
    mysqli \
    gd \
    curl \
    xml

# Setup Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# We need a user with the same UID/GID as the host user
# so when we execute CLI commands, all the host file's permissions and ownership remain intact.
# Otherwise commands from inside the container would create root-owned files and directories.
ARG uid
RUN useradd -G www-data,root -u $uid -d /home/wcv-developer wcv-developer
RUN mkdir -p /home/wcv-developer/.composer && \
    chown -R wcv-developer:wcv-developer /home/wcv-developer


