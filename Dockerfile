FROM ubuntu:14.04
MAINTAINER Parag Bharne<pari.bharne>


RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install apache2
RUN apt-get install -y nano  php5 libapache2-mod-php5 php5-mysql php5-curl php5-gd php5-intl php-pear
RUN apt-get install -y php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite
RUN apt-get install -y php5-tidy php5-xmlrpc php5-xsl
RUN apt-get install -y git openssl  && apt-get install -y supervisor
RUN apt-get install -y mysql-client
RUN apt-get -y install unzip nano
RUN apt-get -y install openssh-server

RUN sudo a2enmod ssl



#RUN mkdir /tmp/.ssh
ADD id_rsa /root/.ssh/id_rsa
ADD id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa.pub
#RUN chown -R www-data:www-data /tmp/.ssh
RUN chmod 0700 /root/.ssh

RUN echo "Host bitbucket.org\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts



RUN rm -rf /var/www/html/index.html
ADD dir.conf  /etc/apache2/mods-enabled/dir.conf
WORKDIR /tmp
#RUN git clone -b master https://github.com/paragbharne/word.git
RUN  git clone -b master  git@bitbucket.org:paragbharne/word1.git
#RUN  git clone -b master https://paragbharne@bitbucket.org/paragbharne/word.git
WORKDIR /tmp/word1/wp-content/plugins
RUN find /tmp/word1/wp-content/plugins/*.zip -exec unzip {} \; || pwd
RUN rm -r /tmp/word1/wp-content/plugins/*.zip || pwd
WORKDIR /tmp/word1

RUN rsync -avP /tmp/word1/ /var/www/html/


ADD 000-default.conf /etc/apache2/sites-available
ADD default-ssl.conf /etc/apache2/sites-available
ADD apache.key /etc/apache2/ssl/
ADD apache.crt /etc/apache2/ssl/

RUN rm -rf /var/www/html/index.html
#ADD dir.conf  /etc/apache2/mods-enabled/dir.conf
#RUN  git clone -b dev https://github.com/paragbharne/wordpress.git /var/www/html
RUN chown -R www-data:www-data /var/www/html/*
ADD wp-config.php /var/www/html

RUN  a2ensite default-ssl.conf
RUN  a2ensite 000-default.conf

EXPOSE 80 443
ENTRYPOINT service apache2 restart  &&  sleep 3600
