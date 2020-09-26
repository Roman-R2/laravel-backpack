up: docker-up
down: docker-down
restart: docker-down docker-up
rebuild: docker-down docker-pull docker-duild docker-up
init: docker-down ready-db-clear docker-pull docker-duild docker-up db-init composer-install

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-duild:
	docker-compose build

tests:
	docker-compose run --rm php-cli vendor/bin/phpunit --colors=always

composer-install:
	docker-compose run --rm php-cli composer install

assets-install:
	docker-compose run --rm node-cli yarn install

assets-dev:
	docker-compose run --rm node-cli yarn run build

db-init: test-wait-db db-ready

ready-db-clear:
	docker run --rm -v ${PWD}/test:/app --workdir=/app alpine rm -f .ready

test-wait-db:
	until docker-compose exec -T postgres pg_isready --timeout=0 --dbname=app ; do sleep 1 ; done

db-ready:
	docker run --rm -v ${PWD}/test:/app --workdir=/app alpine touch .ready

seeds:
	docker-compose run --rm php-cli php artisan db:wipe
	docker-compose run --rm php-cli php artisan migrate
	docker-compose run --rm php-cli composer dump-autoload -o
	docker-compose run --rm php-cli php artisan db:seed

my:
	sudo chown -R ${USER}:${USER} ossix
	sudo chown -R ${USER}:www-data ./ossix/storage
	sudo chown -R ${USER}:www-data ./ossix/bootstrap/cache
	chmod -R 775 ./ossix/storage
	chmod -R 775 ./ossix/bootstrap/cache

