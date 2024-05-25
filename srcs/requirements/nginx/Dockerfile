FROM    debian:oldstable

RUN     apt update -y && apt upgrade -y
RUN     apt install -y nginx openssl
RUN     openssl req -batch -x509 -sha256 -nodes -newkey rsa:2048 -days 365 \
            -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt

COPY    ./conf/https.conf /etc/nginx/conf.d

EXPOSE  443

CMD     [ "nginx", "-g", "daemon off;" ]