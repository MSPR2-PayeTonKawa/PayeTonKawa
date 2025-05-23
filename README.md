# PayeTonKawa - Coffee Microservices Platform

This repository orchestrates the PayeTonKawa microservices architecture, which consists of three independent microservices:

- **Customer Service**: Manages customer data and authentication
- **Product Service**: Handles product catalog and inventory
- **Order Service**: Processes orders and payments

Each microservice has its own repository, database, and API, following best practices for microservice architecture.

## Architecture Overview

- 3 Laravel microservices with REST APIs
- RabbitMQ message broker for inter-service communication
- MySQL databases (one per service)
- Docker containerization
- CI/CD with GitHub Actions

## Prerequisites

- Docker and Docker Compose
- Git
- PHP 8.4+ (for local development outside Docker)
- Composer (for local development outside Docker)

## Getting Started

### Clone the Repositories

```bash
# Clone the central repository
git clone https://github.com/MSPR2-PayeTonKawa/PayeTonKawa.git

# Clone the microservice repositories
git clone https://github.com/MSPR2-PayeTonKawa/PayeTonKawa-Customers.git
git clone https://github.com/MSPR2-PayeTonKawa/PayeTonKawa-Products.git
git clone https://github.com/MSPR2-PayeTonKawa/PayeTonKawa-Orders.git
```

### Directory Structure

Ensure all repositories are cloned at the same level:

```
/your-projects-folder/
├── PayeTonKawa/
├── PayeTonKawa-Customers/
├── PayeTonKawa-Products/
└── PayeTonKawa-Orders/
```

### Start the Development Environment

```bash
cd PayeTonKawa
docker compose up -d
```

This will:
1. Build all Docker images
2. Start all containers (APIs, databases, RabbitMQ)
3. Mount the code as volumes for live development

### Run Database Migrations

```bash
# For Customer Service
docker exec PTK-api-customers php artisan migrate

# For Product Service
docker exec PTK-api-products php artisan migrate

# For Order Service
docker exec PTK-api-orders php artisan migrate
```

## Accessing the Services

- **Customer API**: http://localhost:8001
- **Product API**: http://localhost:8002
- **Order API**: http://localhost:8003
- **RabbitMQ Management**: http://localhost:15672 (user: user, password: pass)

## Development Workflow

### Making Changes

Since the code is mounted as volumes, any changes you make to the source code in each repository will be immediately reflected in the running containers.

### Running Commands Inside Containers

```bash
# Run Artisan commands
docker exec PTK-api-customers php artisan make:model Customer -m

# Run Composer commands
docker exec PTK-api-products composer require darkaonline/l5-swagger
```

### Adding Swagger Documentation

Each microservice can have its own Swagger documentation:

```bash
# Install Swagger in each microservice
docker exec PTK-api-customers composer require darkaonline/l5-swagger
docker exec PTK-api-products composer require darkaonline/l5-swagger
docker exec PTK-api-orders composer require darkaonline/l5-swagger

# Generate documentation
docker exec PTK-api-customers php artisan l5-swagger:generate
```

Access the Swagger UI at:
- http://localhost:8001/api/documentation
- http://localhost:8002/api/documentation
- http://localhost:8003/api/documentation

## Stopping the Environment

```bash
# Stop all containers
docker compose down

# Stop and remove volumes (will delete database data)
docker compose down -v
```

## CI/CD Pipeline

The CI/CD pipeline is configured in `.github/workflows/ci-cd.yml` and orchestrates the testing and deployment of all microservices.

## Troubleshooting

### Database Connection Issues

If you encounter database connection issues, ensure the environment variables in each microservice's `.env` file are correctly pointing to the Docker container names:

```
DB_HOST=PTK-db-customers  # for Customer Service
DB_HOST=PTK-db-products   # for Product Service
DB_HOST=PTK-db-orders     # for Order Service
```

### Permission Issues

If you encounter permission issues with storage or cache directories:

```bash
docker exec PTK-api-customers chmod -R 775 storage bootstrap/cache
docker exec PTK-api-products chmod -R 775 storage bootstrap/cache
docker exec PTK-api-orders chmod -R 775 storage bootstrap/cache
``` 