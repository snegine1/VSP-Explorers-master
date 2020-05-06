FROM ubuntu:14.04.3

RUN apt-get update

# common tools
RUN apt-get -y install vim unzip sysv-rc sysv-rc systemd

# apache2
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2

# mysql
RUN echo "mysql-server mysql-server/root_password password pw2mysql" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password pw2mysql" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --fix-missing install mysql-server

# php
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5 libapache2-mod-php5 php5-mcrypt php5-mysql

RUN apt-get -y install lynx
RUN apt-get -y install libpng-dev libfreetype6
RUN apt-get -y install php5-dev
RUN apt-get -y install bison flex libfreetype6-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install phpmyadmin
RUN apt-get -y install dbus

RUN echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# post installation
COPY php.ini /etc/php5/apache2/
COPY config.inc.php /etc/phpmyadmin/
COPY start-script.sh libming-ming-0_4_8.zip /root/
COPY vsp-explorers.zip /var/www/html/

RUN echo "set background=dark" >> /root/.vimrc
RUN chmod +x /root/start-script.sh 

# build php extension
RUN cd /root \
 && unzip -q libming-ming-0_4_8.zip \
 && cd libming-ming-0_4_8 \
 && ./autogen.sh \
 && ./configure --enable-php \
 && make \
 && cp /root/libming-ming-0_4_8/php_ext/.libs/ming.so \
   /root/libming-ming-0_4_8/src/.libs/libming.so.1 \
   /root/libming-ming-0_4_8/src/.libs/libming.so.1.4.7 \
   /usr/lib/php5/20121212/

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

EXPOSE 80

CMD /root/start-script.sh

