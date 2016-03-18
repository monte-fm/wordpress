#!/bin/bash
service mysql start
service php5-fpm start
service nginx start
service ssh start
echo "create database wordpress" | mysql -uroot -proot
echo "CREATE USER 'wp'@'%' IDENTIFIED BY 'K7jtHs9Qkr';" | mysql -uroot -proot
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp'@'%';" | mysql -uroot -proot
echo "FLUSH PRIVILEGES;" | mysql -uroot -proot

cd /var/www/ && tar -zxvf latest.tar.gz
rm /var/www/latest.tar.gz
mv /root/autostart /root/autostart.sh

