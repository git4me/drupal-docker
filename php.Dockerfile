FROM alpine:edge
MAINTAINER Onni Hakala <onni.hakala@keksi.io>

RUN \
	##
    # Install php7
    # - These repositories are in 'testing' repositories but it's much more stable/easier than compiling our own php.
    ##
    apk add --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ \
    php7 php7-fpm \
    php7-session php7-opcache php7-phar \
    php7-mcrypt php7-curl php7-zlib php7-openssl \
    php7-soap php7-json php7-xml php7-xmlreader php7-simplexml \
    php7-pdo_mysql php7-mysqli php7-mysqlnd php7-pdo \
    php7-redis php7-mongodb php7-memcached \
    php7-mbstring php7-intl php7-iconv \
    php7-gd php7-dom \
    php7-ctype \

    # Used by phpunit tests
    php7-tokenizer \
   	
    # Install mail client and dev dependencies
    && apk add --update curl msmtp bash \

    ##
    # Install composer
    ##
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo \

    # Remove cache and tmp files
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

ENV PORT=9000 \
	PROJECT_ROOT=/var/www/project

# Install msmtp wrapper which acts like sendmail
RUN \
	rm /usr/sbin/sendmail \
	&& curl -L -o /usr/sbin/sendmail https://gist.githubusercontent.com/onnimonni/e7f2a5199d6dc719ffd32dc4d6ac1902/raw/bdd38dc3d1ab5c9308b14b93eaafbb87f28454dc/sendmail \
	&& chmod +x /usr/sbin/sendmail

RUN set -ex \
	&& cd /etc/php7/ \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo "listen = [::]:\${PORT}"; \
	} | tee php-fpm.d/zz-docker.conf \
	&& { \
		echo '[opcache]'; \
		echo 'opcache.enable = 1'; \
		echo 'opcache.memory_consumption = 128'; \
		echo 'opcache.max_accelerated_files = 1000'; \
		echo; \
	} | tee conf.d/opcache.conf \
	# Allow more resources for php-fpm
	&& sed -i '/^pm.max_children/c\pm.max_children = 5' php-fpm.d/www.conf \
	&& sed -i '/^pm.min_spare_servers/c\pm.min_spare_servers = 1' php-fpm.d/www.conf \
	&& sed -i '/^pm.max_spare_servers/c\pm.max_spare_servers = 2' php-fpm.d/www.conf

EXPOSE ${PORT}
WORKDIR ${PROJECT_ROOT}
CMD ["php-fpm7"]