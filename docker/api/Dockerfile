FROM docker.io/debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    supervisor \
    nginx \
    php-fpm \
    php-ctype \
    php-curl \
    php-mbstring \
    php-mysql \
    php-xml \
    php-xdebug \
    php-gd \
    composer \
    netcat-openbsd
COPY 20-xdebug.ini /etc/php/8.2/fpm/conf.d
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
STOPSIGNAL SIGQUIT
COPY ./launcher.sh /usr/bin/launcher.sh
CMD ["/bin/bash", "/usr/bin/launcher.sh"]
