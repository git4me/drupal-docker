PROJECT_ROOT = /var/www/project
PWD = $(shell pwd)

init:
	# Install composer packages
	docker-compose run --no-deps --entrypoint="" --rm -v $(PWD):$(PROJECT_ROOT) php composer install

update:
	# Update composer packages
	docker-compose run --no-deps --entrypoint="" --rm -v $(PWD):$(PROJECT_ROOT) php composer update

reload:
	docker-compose build
	docker-compose up -d --force-recreate

start:
	docker-compose up -d 

stop:
	docker-compose stop

destroy: stop
	docker-compose rm