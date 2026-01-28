@echo off
echo 🏦 Digital Banking Platform - Quick Start Script
echo ================================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker and try again.
    exit /b 1
)

echo ✅ Docker is running
echo.

REM Stop any existing containers
echo 🛑 Stopping existing containers...
docker-compose down

echo.
echo 🏗️  Building services...
docker-compose build

echo.
echo 🚀 Starting all services...
docker-compose up -d

echo.
echo ⏳ Waiting for services to be ready...
timeout /t 10 /nobreak >nul

echo.
echo ✅ Digital Banking Platform is ready!
echo.
echo 📱 Access the application:
echo    Frontend:         http://localhost:3000
echo    Auth API:         http://localhost:3001
echo    Accounts API:     http://localhost:3002
echo    Transactions API: http://localhost:3003
echo.
echo 📊 View logs with: docker-compose logs -f
echo 🛑 Stop services with: docker-compose down
echo.
echo Happy banking! 💰
