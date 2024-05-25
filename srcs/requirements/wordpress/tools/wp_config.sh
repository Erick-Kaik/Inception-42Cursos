#!/bin/sh

chown -R www-data:www-data /var/www/

sudo -u www-data sh -c "wp core download"
sudo -u www-data sh -c "wp config create --dbname=$MDB_DATABASE --dbuser=$MDB_USER --dbpass=$MDB_PASS --dbhost=mariadb --dbcharset='utf8'"
sudo -u www-data sh -c "wp core install --url=$URL --title=Inception --admin_user=$ADM_USER --admin_password=$ADM_PASS --admin_email=$ADM_MAIL --skip-email"
sudo -u www-data sh -c "wp user create $USER_NAME $USER_MAIL --role=author --user_pass=$USER_PASS"
sudo -u www-data sh -c "wp plugin update --all"

ln -s $(find /usr/sbin -name 'php-fpm*') /usr/bin/php-fpm

exec /usr/bin/php-fpm -F