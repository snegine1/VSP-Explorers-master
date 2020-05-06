#!/bin/bash

# uncompress videobill application
cd /var/www/html
unzip -q vsp-explorers.zip
mv vsp-explorers/* .
rmdir vsp-explorers
rm vsp-explorers.zip

# Initial setup of MySQL database server and start-up MySQL server
mysqld_safe --skip-grant-tables &
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
mysql_install_db --user=mysql --ldata=/var/lib/mysql
service mysql start

# create database "db_vsp_explorer" and tables with data in it
export MYSQL_PWD=pw2mysql
mysql -u root < /var/www/html/doc/db_videobill_setup.sql


# start-up Apache server
a2enmod rewrite
service apache2 start

tail -F /var/log/apache2/access.log
