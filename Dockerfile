FROM php:8.1-apache
RUN a2enmod rewrite

# 安装相关拓展
RUN apt-get update && apt-get install -y imagemagick libmagickwand-dev && pecl install imagick && docker-php-ext-install bcmath && docker-php-ext-install pdo_mysql
RUN pecl install redis && docker-php-ext-enable redis

RUN { \
    echo 'post_max_size = 100M'; \
    echo 'upload_max_filesize = 100M'; \
    echo 'max_execution_time = 600S'; \
    echo 'extension=redis.so'; \
} > /usr/local/etc/php/conf.d/docker-php-upload.ini;

RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.accelerated_files=10000'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.revalidate_freq=1'; \
    echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    echo 'apc.enable=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini; \
    echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini; \
    mkdir /var/www/data; \
    chown -R www-data:root /var/www; \
    chmod -R g+w /var/www;

COPY . /var/www/lsky/

# 配置 Apache DocumentRoot 指向 public 目录
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/lsky/public|' /etc/apache2/sites-available/000-default.conf \
    && echo "<Directory /var/www/lsky/public>\n    AllowOverride All\n    Require all granted\n</Directory>" >> /etc/apache2/sites-available/000-default.conf

VOLUME /var/www/lsky
EXPOSE 80
CMD ["apache2-foreground"]
