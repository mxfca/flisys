# ########################################################################### #
#
# 				'########:'##:::::::'####::'######::'##:::'##::'######::
# 				 ##.....:: ##:::::::. ##::'##... ##:. ##:'##::'##... ##:
# 				 ##::::::: ##:::::::: ##:: ##:::..:::. ####::: ##:::..::
# 				 ######::: ##:::::::: ##::. ######::::. ##::::. ######::
# 				 ##...:::: ##:::::::: ##:::..... ##:::: ##:::::..... ##:
# 				 ##::::::: ##:::::::: ##::'##::: ##:::: ##::::'##::: ##:
# 				 ##::::::: ########:'####:. ######::::: ##::::. ######::
# 				..::::::::........::....:::......::::::..::::::......:::
#
# ########################################################################### #
# This file is part of FliSys.
# 
# FliSys is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version
# 
# FliSys is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details
# 
# You should have received a copy of the GNU General Public License
# along with FliSys. If not, see <https://www.gnu.org/licenses/>.
# ########################################################################### #
# This Dockerfile is intend to be used in a production/QA/Test environment.
# For development purposes, use Dockerfile-dev.
# ########################################################################### #
FROM debian:latest

LABEL flisys_version="4.0.0" environment="production"

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
# To enable proxy, fill and uncomment lines below (https://docs.docker.com/network/proxy/#use-environment-variables)
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
RUN	rm -f /etc/apache2/ports.conf \
  && rm -f /etc/apache2/conf-enabled/security.conf \
  && rm -f /etc/apache2/conf-enabled/serve-cgi-bin.conf \
  && rm -f /etc/apache2/conf-available/security.conf \
  && rm -rf /etc/apache2/sites-enabled/* \
  && rm -rf /etc/apache2/sites-available/* \
  && rm -f /etc/logrotate.d/apache2 \
  && /usr/sbin/a2enmod ssl rewrite php7.3

# Copy predefined configurations and files
COPY docker_config/http/ports.conf /etc/apache2/
COPY docker_config/http/security.conf /etc/apache2/conf-available/
COPY docker_config/http/000-default.conf /etc/apache2/sites-available/
COPY docker_config/http/gen.cert /etc/ssl/
COPY docker_config/logrotate/apache.conf /etc/logrotate.d/
COPY docker_config/logrotate/flisys.conf /etc/logrotate.d/
COPY src/ /var/www/flisys/
COPY docker_config/http/dockerStart.sh /usr/local/sbin/

# Set last permissions and configs
RUN /usr/bin/openssl req -config /etc/ssl/gen.cert -x509 -nodes -days 90 -newkey rsa:2048 -keyout /etc/apache2/certs/flisys.key -out /etc/apache2/certs/flisys.crt \
  && rm -f /etc/ssl/gen.cert \
  && rm -rf /var/www/html \
  && ln -s /etc/apache2/conf-available/security.conf /etc/apache2/conf-enabled/security.conf \
  && ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf \
  && chown -R 0:2001 /etc/apache2/certs \
  && chown 0:0 /etc/apache2/ports.conf \
  && chown -R 2001:2001 /var/www/flisys \
  && chmod -R 775 /etc/apache2/certs \
  && chmod 644 /etc/apache2/ports.conf \
  && chmod -R 750 /var/www/flisys \
  && chmod +x /usr/local/sbin/dockerStart.sh

# Expose ports
EXPOSE 80
EXPOSE 443

ENTRYPOINT [ "/usr/local/sbin/docker_start.sh" ]
