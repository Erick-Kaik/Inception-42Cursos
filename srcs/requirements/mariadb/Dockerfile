FROM    debian:oldstable

ARG     MDB_DATABASE
ARG     MDB_USER
ARG     MDB_PASS

RUN     apt update -y && apt upgrade -y
RUN     apt install mariadb-server -y

RUN     echo "[mysqld] \n\
                skip-networking=0 \n\
                skip-bind-address" >> /etc/mysql/my.cnf

RUN     service mariadb start && mariadb -u root -e \
            "CREATE DATABASE IF NOT EXISTS ${MDB_DATABASE}; \
            CREATE USER '${MDB_USER}}'@'%' IDENTIFIED BY '${MDB_PASS}'; \
            GRANT ALL ON ${MDB_DATABASE}.* TO '${MDB_USER}'@'%' IDENTIFIED BY '${MDB_PASS}'; \
            FLUSH PRIVILEGES;" && \
            service mariadb stop

CMD     [ "mysqld_safe" ]