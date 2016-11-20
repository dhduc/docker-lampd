FROM ubuntu:14.04
MAINTAINER Duc Dao

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

# manually set mirror to SG
RUN sed -i "s/archive.ubuntu.com/download.nus.edu.sg/" /etc/apt/sources.list

# base update
RUN apt-get update && apt-get upgrade -y

# apache2
RUN apt-get install -y apache2
RUN a2enmod rewrite
RUN sed -i '/ServerRoot "\/etc\/apache2"/ a ServerName localhost' /etc/apache2/apache2.conf

# php5 and necessary modules for Magento
RUN apt-get install -y php5 php5-gd php5-intl php5-mcrypt curl php5-curl mysql-client php5-mysql
RUN php5enmod mcrypt

# tweak some PHP settings for local development
RUN sed -i -r "s/display_errors = Off/display_errors = On/" /etc/php5/apache2/php.ini
RUN sed -i -r "s/^memory_limit = .*/memory_limit = 512M/" /etc/php5/apache2/php.ini
RUN sed -i -r "s/^;realpath_cache_size = .*/realpath_cache_size = 64k/" /etc/php5/apache2/php.ini
RUN sed -i -r "s/^;realpath_cache_ttl = .*/realpath_cache_ttl = 3600/" /etc/php5/apache2/php.ini
RUN sed -i -r "s/post_max_size = .*/post_max_size = 48M/" /etc/php5/apache2/php.ini
RUN sed -i -r "s/upload_max_filesize = .*/upload_max_filesize = 32M/" /etc/php5/apache2/php.ini

RUN sed -i -r "s/display_errors = Off/display_errors = On/" /etc/php5/cli/php.ini
RUN sed -i -r "s/^memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
RUN sed -i -r "s/^;realpath_cache_size = .*/realpath_cache_size = 64k/" /etc/php5/cli/php.ini
RUN sed -i -r "s/^;realpath_cache_ttl = .*/realpath_cache_ttl = 3600/" /etc/php5/cli/php.ini
RUN sed -i -r "s/post_max_size = .*/post_max_size = 48M/" /etc/php5/cli/php.ini
RUN sed -i -r "s/upload_max_filesize = .*/upload_max_filesize = 32M/" /etc/php5/cli/php.ini

# xdebug for remote debug and keep it disabled
RUN apt-get install -y php5-xdebug
RUN php5dismod xdebug
RUN sed -i '/zend_extension=xdebug.so/ a xdebug.remote_enable=On\nxdebug.remote_connect_back=On' /etc/php5/mods-available/xdebug.ini

# public_html
VOLUME /var/www/myweb
COPY conf/vhost-myweb.conf /etc/apache2/sites-enabled/000-default.conf

# I need it to restart once before supervisor to work. Harmless anyway.
RUN service apache2 restart

# supervisor - we can restart apache without stopping the container
RUN apt-get install -y supervisor
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord"]
#CMD /usr/sbin/apache2ctl -D FOREGROUND