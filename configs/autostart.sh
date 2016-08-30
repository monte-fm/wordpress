#!/bin/bash
service mysql start
service php7.0-fpm start
service nginx start
service ssh start

cd /var/www/ && tar -zxvf latest.tar.gz
rm /var/www/latest.tar.gz
mv /root/autostart /root/autostart.sh
chown -R www-data:www-data /var/www/wordpress

