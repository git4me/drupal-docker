PROJECT_ROOT = /var/www/project
PWD = $(shell pwd)

# Set HOST_IP depending on system
# In MacOS we need to add custom mapping 10.254.254.254 -> 127.0.0.1
ifeq ($(shell uname -s),Darwin)
	HOST_IP=10.254.254.254
else
	HOST_IP=$(shell ifconfig docker0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
endif
export HOST_IP

# Alias for running command inside php docker container
run_docker_php = HOST_IP=$(HOST_IP) docker-compose run --no-deps --entrypoint="" --rm -v $(PWD):$(PROJECT_ROOT) php
install: start
	# Install composer packages
	$(run_docker_php) composer install

update: start
	# Update composer packages
	$(run_docker_php) composer update

test:
	$(run_docker_php) vendor/bin/codecept build
	$(run_docker_php) vendor/bin/codecept run

shell:
	$(run_docker_php) sh

reload:
	docker-compose build
	docker-compose up -d --force-recreate

start:
	docker-compose up -d

stop:
	docker-compose stop

destroy: stop
	docker-compose rm

logs:
	docker-compose logs