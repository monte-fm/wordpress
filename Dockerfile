FROM      ubuntu
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#install PHP
RUN apt-get update
RUN apt-get install -y nano nginx wget
RUN apt-get install -y php5-fpm php5-mysql
COPY configs/nginx/default /etc/nginx/sites-available/default

#MySQL install + password
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN sudo apt-get  install -y mysql-server mysql-client
RUN service mysql start
RUN mysql -uroot -proot -e 'create database wordpress'

# SSH service
RUN sudo apt-get install -y openssh-server openssh-client
RUN sudo mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#change 'pass' to your secret password
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#configs bash start
COPY configs/autostart.sh /root/autostart.sh
RUN chmod +x /root/autostart.sh
COPY configs/bash.bashrc /etc/bash.bashrc

#aliases
RUN alias ll='ls -la'

#install Wordpress
RUN mkdir -p /var/www
RUN cd /var/www
RUN wget http://wordpress.org/latest.tar.gz
RUN tar latest.tar.gz
RUN rm /var/www/latest.tar.gz
RUN chown -R www-data:www-data /var/www/wordpress
COPY configs/wp-config.php /var/www/wordpress/wp-config.php

#open ports
EXPOSE 80 22
