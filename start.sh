#!/bin/bash

echo "🏦 Digital Banking Platform - Quick Start Script"
echo "================================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

echo ""
echo "🏗️  Building services..."
docker-compose build

echo ""
echo "🚀 Starting all services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "✅ Digital Banking Platform is ready!"
echo ""
echo "📱 Access the application:"
echo "   Frontend:        http://localhost:3000"
echo "   Auth API:        http://localhost:3001"
echo "   Accounts API:    http://localhost:3002"
echo "   Transactions API: http://localhost:3003"
echo ""
echo "📊 View logs with: docker-compose logs -f"
echo "🛑 Stop services with: docker-compose down"
echo ""
echo "Happy banking! 💰"
