SHELL := /bin/bash

.PHONY: up down restart build ps logs migrate migrate-fresh seed install update swagger clean help

up:
	docker compose up -d

down:
	docker compose down

restart: down up

build:
	docker compose build --no-cache

ps:
	docker compose ps

logs:
	docker compose logs -f

migrate:
	docker exec PTK-api-customers php artisan migrate
	docker exec PTK-api-products php artisan migrate
	docker exec PTK-api-orders php artisan migrate

migrate-fresh:
	docker exec PTK-api-customers php artisan migrate:fresh
	docker exec PTK-api-products php artisan migrate:fresh
	docker exec PTK-api-orders php artisan migrate:fresh

seed:
	docker exec PTK-api-customers php artisan db:seed
	docker exec PTK-api-products php artisan db:seed
	docker exec PTK-api-orders php artisan db:seed

install:
	docker exec PTK-api-customers composer install
	docker exec PTK-api-products composer install
	docker exec PTK-api-orders composer install

update:
	docker exec PTK-api-customers composer update
	docker exec PTK-api-products composer update
	docker exec PTK-api-orders composer update

swagger:
	docker exec PTK-api-customers composer require darkaonline/l5-swagger --quiet
	docker exec PTK-api-products composer require darkaonline/l5-swagger --quiet
	docker exec PTK-api-orders composer require darkaonline/l5-swagger --quiet
	docker exec PTK-api-customers php artisan l5-swagger:generate
	docker exec PTK-api-products php artisan l5-swagger:generate
	docker exec PTK-api-orders php artisan l5-swagger:generate

clean:
	docker compose down -v
	docker system prune -f

fix-permissions:
	docker exec PTK-api-customers chmod -R 775 storage bootstrap/cache
	docker exec PTK-api-products chmod -R 775 storage bootstrap/cache
	docker exec PTK-api-orders chmod -R 775 storage bootstrap/cache

test:
	docker exec PTK-api-customers php artisan test
	docker exec PTK-api-products php artisan test
	docker exec PTK-api-orders php artisan test

cache-clear:
	docker exec PTK-api-customers php artisan cache:clear
	docker exec PTK-api-products php artisan cache:clear
	docker exec PTK-api-orders php artisan cache:clear
	docker exec PTK-api-customers php artisan config:clear
	docker exec PTK-api-products php artisan config:clear
	docker exec PTK-api-orders php artisan config:clear
	docker exec PTK-api-customers php artisan route:clear
	docker exec PTK-api-products php artisan route:clear
	docker exec PTK-api-orders php artisan route:clear

help:
	@echo "Available commands:"
	@echo "  make up               - Start all containers"
	@echo "  make down             - Stop all containers"
	@echo "  make restart          - Restart all containers"
	@echo "  make build            - Rebuild all containers"
	@echo "  make ps               - Show container status"
	@echo "  make logs             - Show container logs"
	@echo "  make migrate          - Run migrations for all services"
	@echo "  make migrate-fresh    - Drop all tables and re-run migrations"
	@echo "  make seed             - Run seeders for all services"
	@echo "  make install          - Install composer dependencies"
	@echo "  make update           - Update composer dependencies"
	@echo "  make swagger          - Install and generate Swagger documentation"
	@echo "  make clean            - Remove all containers and volumes"
	@echo "  make fix-permissions  - Fix storage and cache permissions"
	@echo "  make test             - Run tests for all services"
	@echo "  make cache-clear      - Clear all caches" 