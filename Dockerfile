FROM php:7.1-apache
LABEL maintainer="taitran.apps@gmail.com"

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        default-libmysqlclient-dev \
        libbz2-dev \
        libmemcached-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmcrypt-dev \
        libmemcachedutil2 \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install bcmath bz2 calendar iconv intl mbstring mcrypt mysqli opcache pdo_mysql pdo_pgsql pgsql soap zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && docker-php-ext-install exif \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && a2enmod rewrite \
    && a2enmod headers


#missing modules
RUN docker-php-ext-install gettext
#RUN docker-php-ext-install imap
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install shmop
RUN docker-php-ext-install sockets
RUN docker-php-ext-install sysvmsg
RUN docker-php-ext-install sysvsem
RUN docker-php-ext-install sysvshm
RUN docker-php-ext-install wddx
RUN docker-php-ext-install xml
#RUN docker-php-ext-install xsl

#modules imp
RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev && rm -r /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

#modules xls
RUN apt-get update
RUN apt-get dist-upgrade
RUN apt-get install libxslt1-dev -y
RUN docker-php-ext-install xsl

#install gmp
RUN apt-get install -y libgmp-dev re2c libmhash-dev libmcrypt-dev file
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN docker-php-ext-configure gmp
RUN docker-php-ext-install gmp

#imagick
RUN apt-get update && apt-get install -y \
    libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
        && docker-php-ext-enable imagick


#GENKI
WORKDIR *WORKSPACE FOLDER*

COPY . *WORKSPACE FOLDER*
COPY docker/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY docker/start.sh /usr/local/bin/start

RUN chown -R www-data:www-data /workspace/GENKI && a2enmod rewrite
RUN chmod u+x /usr/local/bin/start 

RUN chmod -R 775 *WORKSPACE FOLDER*/storage/logs
RUN chmod -R 775 *WORKSPACE FOLDER*/public

CMD ["/usr/local/bin/start"]
