FROM    debian:oldstable

ARG     MDB_DATABASE
ARG     MDB_USER
ARG     MDB_PASS

RUN     apt update -y && apt upgrade -y

RUN     apt install -y \
            php-fpm \
            php-mysql \
            mariadb-client \
            wget \
            sudo

WORKDIR /var/www/html/

RUN     sed -i.default "/^listen\s=.*/c\listen = 0.0.0.0:9000" \
            /etc/php/[0-9]*.[0-9]*/fpm/pool.d/www.conf

COPY    ./tools/wp_config.sh /tmp/wp_config.sh

RUN     wget https://wordpress.org/latest.tar.gz && \
            tar -xzf latest.tar.gz && \
            mv wordpress/* . && \
            rm -rf wordpress && \
            rm -rf latest.tar.gz

RUN     wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    	    chmod +x wp-cli.phar && \
    	    mv wp-cli.phar /usr/bin/wp

RUN     mkdir -p /run/php

CMD     [ "sh", "/tmp/wp_config.sh" ]