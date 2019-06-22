# vim:set ft=dockerfile:
FROM debian:latest

LABEL flisys_version="4.0.0"

# install system and required tolls
RUN apt-get update && apt-get install -y --no-install-recomends \
	apache2 \
	libapache2-mod-php \
	php-common \
	php-mbstring \
	php-mysql \
	php-ssh2 \
	php7.0-curl \
	openssl \
	logrotate \
	locales \
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
	&& dpkg-reconfigure -f noninteractive tzdata \
	&& /usr/sbin/a2enmod ssl rewrite php7.0 \
	&& rm -f /etc/apache2/ports.conf \
	&& rm -f /etc/apache2/conf-enabled/security.conf \
	&& rm -f /etc/apache2/sites-enabled/* \
	&& rm -f /etc/apache2/sites-available/* \
	&& rm -f /etc/logrotate.d/apache2

# Copy predefined configuration and files
COPY ports.conf /etc/apache2/
COPY security.conf /etc/apache2/conf-available/
COPY 000-default.conf /etc/apache2/sites-available/
COPY gen.cert /etc/ssl/
COPY ../logrotate/apache.conf /etc/logrotate.d/
COPY ../logrotate/flisys.conf /etc/logrotate.d/
COPY ../../src/ /var/www/flisys/

# Set last permissions and configs

# Expose ports
EXPOSE 80
EXPOSE 443

ENTRYPOINT [ "" ]
