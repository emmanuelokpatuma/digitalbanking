.PHONY: help build up down restart logs clean install test

help: ## Show this help message
	@echo '🏦 Digital Banking Platform - Available Commands'
	@echo '================================================'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build all Docker images
	@echo "🏗️  Building all services..."
	docker-compose build

up: ## Start all services
	@echo "🚀 Starting all services..."
	docker-compose up -d
	@echo "✅ Services started! Frontend: http://localhost:3000"

down: ## Stop all services
	@echo "🛑 Stopping all services..."
	docker-compose down

restart: down up ## Restart all services

logs: ## View logs from all services
	docker-compose logs -f

clean: ## Stop services and remove volumes
	@echo "🧹 Cleaning up..."
	docker-compose down -v
	@echo "✅ Cleanup complete!"

install-auth: ## Install dependencies for auth-api
	cd auth-api && npm install

install-accounts: ## Install dependencies for accounts-api
	cd accounts-api && npm install

install-transactions: ## Install dependencies for transactions-api
	cd transactions-api && npm install

install-frontend: ## Install dependencies for frontend
	cd digitalbank-frontend && npm install

install: install-auth install-accounts install-transactions install-frontend ## Install all dependencies

dev-auth: ## Run auth-api in development mode
	cd auth-api && npm run dev

dev-accounts: ## Run accounts-api in development mode
	cd accounts-api && npm run dev

dev-transactions: ## Run transactions-api in development mode
	cd transactions-api && npm run dev

dev-frontend: ## Run frontend in development mode
	cd digitalbank-frontend && npm run dev

status: ## Check status of all services
	@echo "📊 Service Status:"
	@docker-compose ps
