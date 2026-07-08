FROM php:8.2-apache-bookworm
RUN apt-get update && apt-get install -y \
    git unzip nano \
    libxml2-dev libpng-dev libonig-dev \
    libicu-dev \
    libc-client2007e-dev libkrb5-dev \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j1 mysqli mbstring gd intl opcache imap
RUN pecl install apcu && docker-php-ext-enable apcu
RUN a2enmod rewrite ssl
WORKDIR /var/www/html
RUN git clone --branch v1.18.4 --depth 1 https://github.com/osTicket/osTicket.git . \
    && cp include/ost-sampleconfig.php include/ost-config.php \
    && chmod 0666 include/ost-config.php \
    && chmod -R 0755 include/i18n

# Keep a pristine copy of include/ for the entrypoint to seed the bind mount from
RUN cp -a include /var/www/html/include-orig

RUN sed -ri -e 's,80,443,' /etc/apache2/sites-available/000-default.conf
RUN sed -i -e '/^<\/VirtualHost>/i SSLEngine on' /etc/apache2/sites-available/000-default.conf
RUN sed -i -e '/^<\/VirtualHost>/i SSLCertificateFile /cert/cert.pem' /etc/apache2/sites-available/000-default.conf
RUN sed -i -e '/^<\/VirtualHost>/i SSLCertificateKeyFile /cert/privkey.pem' /etc/apache2/sites-available/000-default.conf
RUN sed -i -e '/^<\/VirtualHost>/i SSLCertificateChainFile /cert/fullchain.pem' /etc/apache2/sites-available/000-default.conf

# Add core osTicket plugins into include-orig/plugins
COPY plugins/ /var/www/html/include-orig/plugins/

# Add English (Great Britain) as a language option
COPY lang/en_GB.phar /var/www/html/include-orig/i18n/en_GB.phar

# Add Scripts Folder (cause you never know but we won't put in /var/www/html)
COPY scripts/ /var/www/scripts/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]
