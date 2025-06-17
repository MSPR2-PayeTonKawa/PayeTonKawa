SHELL := /bin/bash

.PHONY: up down restart build ps logs migrate migrate-fresh seed install update swagger clean help start-all setup listeners stop-listeners migrate-reset rabbitmq-status test-rabbitmq

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

migrate-reset:
	@echo "🗑️ Resetting all databases and migrations..."
	docker exec PTK-api-customers php artisan migrate:fresh --force
	docker exec PTK-api-products php artisan migrate:fresh --force
	docker exec PTK-api-orders php artisan migrate:fresh --force

migrate:
	@echo "🗄️ Running migrations for all services..."
	docker exec PTK-api-customers php artisan migrate --force
	docker exec PTK-api-products php artisan migrate --force
	docker exec PTK-api-orders php artisan migrate --force

migrate-fresh:
	docker exec PTK-api-customers php artisan migrate:fresh --seed
	docker exec PTK-api-products php artisan migrate:fresh --seed
	docker exec PTK-api-orders php artisan migrate:fresh --seed

seed:
	docker exec PTK-api-customers php artisan db:seed
	docker exec PTK-api-products php artisan db:seed
	docker exec PTK-api-orders php artisan db:seed

install:
	@echo "🔧 Fixing Git ownership and installing dependencies..."
	docker exec PTK-api-customers git config --global --add safe.directory /var/www/html
	docker exec PTK-api-products git config --global --add safe.directory /var/www/html
	docker exec PTK-api-orders git config --global --add safe.directory /var/www/html
	@echo "🧹 Clearing Composer cache..."
	docker exec PTK-api-customers composer clear-cache
	docker exec PTK-api-products composer clear-cache
	docker exec PTK-api-orders composer clear-cache
	@echo "📦 Installing RabbitMQ dependencies..."
	docker exec PTK-api-customers composer require php-amqplib/php-amqplib --quiet
	docker exec PTK-api-products composer require php-amqplib/php-amqplib --quiet
	docker exec PTK-api-orders composer require php-amqplib/php-amqplib --quiet
	@echo "🚀 Installing all dependencies..."
	docker exec PTK-api-customers composer install --no-dev --optimize-autoloader
	docker exec PTK-api-products composer install --no-dev --optimize-autoloader
	docker exec PTK-api-orders composer install --no-dev --optimize-autoloader

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

start-all: up install migrate-reset
	@echo "✅ All microservices are now running!"
	@echo "🐰 RabbitMQ listeners start automatically with each service"
	@echo "🔗 Access points:"
	@echo "  - Customers API: http://localhost:8001/api/test"
	@echo "  - Products API: http://localhost:8002/api/test"
	@echo "  - Orders API: http://localhost:8003/api/test"
	@echo "  - RabbitMQ Management: http://localhost:15672 (payetonkawa / kawa2024!)"

setup: build start-all fix-permissions cache-clear
	@echo "🚀 Complete setup finished!"

listeners:
	@echo "🐰 Starting RabbitMQ listeners for all services..."
	docker exec -d PTK-api-customers php artisan events:listen
	docker exec -d PTK-api-products php artisan events:listen  
	docker exec -d PTK-api-orders php artisan events:listen
	@echo "✅ All listeners are now running in background"

stop-listeners:
	@echo "🛑 Stopping RabbitMQ listeners..."
	docker exec PTK-api-customers pkill -f "artisan events:listen" || true
	docker exec PTK-api-products pkill -f "artisan events:listen" || true
	docker exec PTK-api-orders pkill -f "artisan events:listen" || true
	@echo "✅ All listeners stopped"

rabbitmq-status:
	@echo "🐰 Checking RabbitMQ status and connections..."
	@echo "📊 RabbitMQ Management Interface: http://localhost:15672"
	@echo "🔌 Container status:"
	docker exec PTK-MessageBroker rabbitmqctl list_connections
	@echo "📋 Queues:"
	docker exec PTK-MessageBroker rabbitmqctl list_queues
	@echo "🔄 Exchanges:"
	docker exec PTK-MessageBroker rabbitmqctl list_exchanges
	@echo "👥 Users:"
	docker exec PTK-MessageBroker rabbitmqctl list_users
	@echo "📡 Checking if listeners are running:"
	docker exec PTK-api-customers ps aux | grep "artisan events:listen" || echo "❌ No customers listener"
	docker exec PTK-api-products ps aux | grep "artisan events:listen" || echo "❌ No products listener"
	docker exec PTK-api-orders ps aux | grep "artisan events:listen" || echo "❌ No orders listener"

test-rabbitmq:
	@echo "🧪 Testing RabbitMQ connections from all services..."
	@echo "📡 Testing Customers service:"
	docker exec PTK-api-customers php artisan rabbitmq:test
	@echo ""
	@echo "📡 Testing Products service:"
	docker exec PTK-api-products php artisan rabbitmq:test
	@echo ""
	@echo "📡 Testing Orders service:"
	docker exec PTK-api-orders php artisan rabbitmq:test

help:
	@echo "Available commands:"
	@echo "  make start-all        - Start all containers, install deps, migrate and start listeners"
	@echo "  make setup            - Complete setup (build + start-all + permissions + cache)"
	@echo "  make listeners        - Start RabbitMQ event listeners for all services"
	@echo "  make stop-listeners   - Stop all RabbitMQ event listeners"
	@echo "  make rabbitmq-status  - Check RabbitMQ status and connections"
	@echo "  make test-rabbitmq    - Test RabbitMQ connections from all services"
	@echo "  make migrate-reset    - Reset all databases and re-run migrations"
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