# vim:set ft=dockerfile:
FROM debian:latest

LABEL flisys_version="4.0.0"

# install system and required tolls
RUN apt-get update && apt-get install -y --no-install-recommends \
  apache2 \
  apache2-bin \
  apache2-data \
  apache2-utils \
  libapache2-mod-php7.3 \
  php7.3-common \
  php7.3-json \
  php7.3-cli \
  php7.3-mbstring \
  php7.3-mysql \
  openssl \
  logrotate \
  locales \
  cron \
  && rm -rf /var/lib/apt/lists/* \
  && /usr/bin/localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Declare Environment Variables
# ----------------------------------------------------------------------------
ENV LANG en_US.utf8
ENV TZ UTC
# To enable proxy, fill and uncomment lines below ()
# ----------------------------------------------------------------------------
# ENV HTTP_PROXY "http://proxy_server:8080"
# ENV FTP_PROXY "http://proxy_server:8080"
# ----------------------------------------------------------------------------
# DO NOT USE HTTPS_PROXY ONCE THE SYSTEM NEED TO USE IT FOR INTERNAL PROCESS
# ----------------------------------------------------------------------------

# Prepare OS
RUN usermod -u 2001 www-data \
  && groupmod -g 2001 www-data \
  && mkdir -p /var/log/apache2/flisys \
  && mkdir -p /var/log/flisys \
  && mkdir -p /etc/apache2/certs \
  && mkdir -p /var/www/flisys \
  && touch /var/www/.rnd \
  && chown -R 0:2001 /var/log/apache2/flisys \
  && chown -R 0:2001 /var/log/flisys \
  && chown -R 0:2001 /etc/apache2/certs \
  && chown -R 2001:2001 /var/www/flisys \
  && chown -R 2001:2001 /var/www/.rnd \
  && dpkg-reconfigure -f noninteractive tzdata

# Prepare Services
RUN	/usr/sbin/a2enmod ssl rewrite php7.3 \
  && rm -f /etc/apache2/ports.conf
  # && rm -f /etc/apache2/conf-enabled/security.conf \
  #&& rm -f /etc/apache2/sites-enabled/* \
  #&& rm -f /etc/apache2/sites-available/* \
  # && rm -f /etc/logrotate.d/apache2

# Copy predefined configuration and files
COPY ports.conf /etc/apache2/
# COPY security.conf /etc/apache2/conf-available/
# COPY 000-default.conf /etc/apache2/sites-available/
# COPY gen.cert /etc/ssl/
# COPY ../logrotate/apache.conf /etc/logrotate.d/
# COPY ../logrotate/flisys.conf /etc/logrotate.d/
# COPY ../../src/ /var/www/flisys/
COPY dockerStart.sh /usr/local/sbin/

# Set last permissions and configs
#RUN /usr/bin/openssl req -config /etc/ssl/gen.cert -x509 -nodes -days 90 -newkey rsa:2048 -keyout /etc/ssl/flisys.key -out /etc/ssl/flisys.crt \
#		&& rm -f /etc/ssl/gen.cert \
#		&& ln -s /etc/apache2/conf-available/security.conf /etc/apache2/conf-enabled/security.conf \
#		&& ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf \
#		&& chown -R 0:2001 /etc/apache2/certs \
RUN chown 0:0 /etc/apache2/ports.conf \
  && chown -R 2001:2001 /var/www/flisys \
# && chmod -R 775 /etc/apache2/certs \
  && chmod 644 /etc/apache2/ports.conf \
  && chmod -R 750 /var/www/flisys \
  && chmod +x /usr/local/sbin/dockerStart.sh

# Expose ports
EXPOSE 80
EXPOSE 443

ENTRYPOINT [ "/usr/local/sbin/dockerStart.sh" ]
