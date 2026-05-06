FROM php:7.2-apache

RUN set -eux; \
    sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list; \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list; \
    sed -i '/buster-updates/d' /etc/apt/sources.list; \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        unzip \
        curl \
        libicu-dev \
        libzip-dev \
        zlib1g-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-jpeg-dir=/usr/include/ \
        --with-freetype-dir=/usr/include/ \
    && docker-php-ext-install -j"$(nproc)" \
        intl \
        mbstring \
        mysqli \
        pdo_mysql \
        zip \
        gd \
        opcache \
    && a2enmod rewrite headers expires deflate filter setenvif \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    groupmod -o -g 1000 www-data; \
    usermod  -o -u 1000 -g 1000 www-data; \
    sed -ri 's/^export APACHE_RUN_USER=.*/export APACHE_RUN_USER=www-data/' /etc/apache2/envvars; \
    sed -ri 's/^export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=www-data/' /etc/apache2/envvars

RUN set -eux; \
    cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/public

    <Directory /var/www/html/public>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

RUN { \
        echo "memory_limit=256M"; \
        echo "max_execution_time=240"; \
        echo "max_input_vars=1500"; \
        echo "upload_max_filesize=64M"; \
        echo "post_max_size=64M"; \
        echo "date.timezone=Europe/Berlin"; \
    } > /usr/local/etc/php/conf.d/typo3.ini

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
