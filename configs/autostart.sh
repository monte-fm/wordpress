#!/bin/bash
service mysql start
service php5-fpm start
service nginx start
service ssh start
mysql -uroot -proot -e 'create database wordpress'
chmod +x /root/autostart /root/autostart.sh
cd /var/www/
tar -zxvf latest.tar.gz
rm /var/www/latest.tar.gz
mv /root/autostart /root/autostart.sh

