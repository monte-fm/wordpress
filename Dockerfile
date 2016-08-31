FROM      ubuntu:14.04.4
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#install Nginx
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y language-pack-en-base
RUN apt-get install -y software-properties-common python-software-properties
RUN echo "postfix postfix/mailname string magento.hostname.com" | sudo debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Magento E-commerce'" | sudo debconf-set-selections
RUN apt-get install -y supervisor postfix wget 
RUN apt-get install -y nano nginx
COPY configs/nginx/default /etc/nginx/sites-available/default
RUN apt-get install -y git git-core vim nano mc tmux curl zip unzip

#Install PHP7
RUN apt-get install -y language-pack-en-base
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y php7.0 php7.0-cli php7.0-common php7.0-cgi php7.0-mysql \
    php7.0-fpm
RUN rm /etc/php/7.0/cgi/php.ini
RUN rm /etc/php/7.0/cli/php.ini
RUN rm /etc/php/7.0/fpm/php.ini
RUN rm /etc/php/7.0/fpm/pool.d/www.conf
COPY configs/php/www.conf /etc/php/7.0/fpm/pool.d/www.conf
COPY configs/php/php.ini  /etc/php/7.0/cgi/php.ini
COPY configs/php/php.ini  /etc/php/7.0/cli/php.ini
COPY configs/php/php.ini  /etc/php/7.0/fpm/php.ini

#Install Percona Mysql 5.6 server
RUN wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb
RUN dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb
RUN rm percona-release_0.1-3.$(lsb_release -sc)_all.deb
RUN apt-get update
RUN echo "percona-server-server-5.6 percona-server-server/root_password password root" | sudo debconf-set-selections
RUN echo "percona-server-server-5.6 percona-server-server/root_password_again password root" | sudo debconf-set-selections
RUN apt-get install -y percona-server-server-5.6
COPY configs/mysql/my.cnf /etc/mysql/my.cnf
RUN service mysql start && echo "create database wordpress" | mysql -uroot -proot
RUN service mysql start && echo "CREATE USER 'wp'@'localhost' IDENTIFIED BY 'K7jtHs9Qkr';" | mysql -uroot -proot
RUN service mysql start && echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp'localhost'';" | mysql -uroot -proot
RUN service mysql start && echo "FLUSH PRIVILEGES;" | mysql -uroot -proot

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

#Install locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

#aliases
RUN echo "alias ll='ls -la'" >> ~/.bashrc

#Add colorful command line
RUN echo "force_color_prompt=yes" >> ~/.bashrc
RUN echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> ~/.bashrc

#install Wordpress
RUN mkdir -p /var/www/wordpress
RUN cd /var/www && wget http://wordpress.org/latest.tar.gz
COPY configs/wp-config.php /var/www/wordpress/wp-config.php
RUN chown -R www-data:www-data /var/www/wordpress
RUN cd /var/www/ && tar -zxvf latest.tar.gz
RUN rm /var/www/latest.tar.gz
RUN chown -R www-data:www-data /var/www

#open ports
EXPOSE 80 22