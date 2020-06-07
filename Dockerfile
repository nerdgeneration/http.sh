FROM alpine:latest

RUN apk add bash supervisor nmap-ncat

COPY docker/http.sh.conf /etc/http.sh.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/www /srv/www

EXPOSE 8080
CMD /usr/bin/supervisord -c /etc/supervisord.conf
