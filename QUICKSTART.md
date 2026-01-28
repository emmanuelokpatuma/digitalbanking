# 🏦 Digital Banking Platform - Quick Reference

## � Project Configuration
- **GCP Project ID**: `charged-thought-485008-q7`
- **Project Number**: 66597
- **Region**: us-central1
- **Container Registry**: `gcr.io/charged-thought-485008-q7`

## �🚀 Quick Start

### Option 1: Using Start Scripts
```bash
# Linux/Mac
./start.sh

# Windows
start.bat
```

### Option 2: Using Make
```bash
make build    # Build all services
make up       # Start all services
make logs     # View logs
make down     # Stop services
make clean    # Clean everything
```

### Option 3: Using Docker Compose
```bash
docker-compose up -d        # Start
docker-compose down         # Stop
docker-compose logs -f      # View logs
docker-compose down -v      # Clean all data
```

## 📱 Service URLs

| Service | URL | Port |
|---------|-----|------|
| Frontend | http://localhost:3000 | 3000 |
| Auth API | http://localhost:3001 | 3001 |
| Accounts API | http://localhost:3002 | 3002 |
| Transactions API | http://localhost:3003 | 3003 |
| Auth DB | localhost:5432 | 5432 |
| Accounts DB | localhost:5433 | 5433 |
| Transactions DB | localhost:5434 | 5434 |

## 🔑 API Quick Reference

### Authentication
```bash
# Register
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe"
}

# Login
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Accounts
```bash
# Create Account
POST /api/accounts
Headers: Authorization: Bearer <token>
{
  "account_type": "checking",
  "currency": "USD"
}

# Get Accounts
GET /api/accounts
Headers: Authorization: Bearer <token>

# Deposit
POST /api/accounts/:id/deposit
Headers: Authorization: Bearer <token>
{
  "amount": 100.00
}
```

### Transactions
```bash
# Transfer
POST /api/transactions/transfer
Headers: Authorization: Bearer <token>
{
  "from_account_id": 1,
  "to_account_id": 2,
  "amount": 100.00,
  "description": "Transfer"
}

# Get Transactions
GET /api/transactions
Headers: Authorization: Bearer <token>
```

## 🐳 Docker Commands

```bash
# Build services
docker-compose build

# Start in background
docker-compose up -d

# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f auth-api

# Stop services
docker-compose down

# Remove everything including volumes
docker-compose down -v

# Restart a service
docker-compose restart auth-api

# Rebuild and start
docker-compose up -d --build
```

## 🛠️ Development Commands

```bash
# Install dependencies
make install

# Run individual services in dev mode
cd auth-api && npm run dev
cd accounts-api && npm run dev
cd transactions-api && npm run dev
cd digitalbank-frontend && npm run dev
```

## 📊 Database Access

```bash
# Connect to auth database
docker exec -it auth-db psql -U postgres -d authdb

# Connect to accounts database
docker exec -it accounts-db psql -U postgres -d accountsdb

# Connect to transactions database
docker exec -it transactions-db psql -U postgres -d transactionsdb
```

## 🔍 Troubleshooting

### Services won't start
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Check service health
```bash
curl http://localhost:3001/health  # Auth API
curl http://localhost:3002/health  # Accounts API
curl http://localhost:3003/health  # Transactions API
```

### View container status
```bash
docker-compose ps
```

### Check logs for errors
```bash
docker-compose logs auth-api | grep -i error
```

## 📦 Project Structure

```
digitalbanking/
├── auth-api/              # Authentication service
├── accounts-api/          # Accounts management
├── transactions-api/      # Transactions & payments
├── digitalbank-frontend/  # React frontend
├── docker-compose.yml     # Container orchestration
├── Makefile              # Build automation
├── start.sh              # Quick start (Linux/Mac)
├── start.bat             # Quick start (Windows)
└── README.md             # Full documentation
```

## 🔐 Default Credentials

Database:
- User: `postgres`
- Password: `password`
- ⚠️ Change in production!

JWT Secret:
- Default: `your-super-secret-jwt-key-change-this`
- ⚠️ Change in production!

## 📝 Testing Flow

1. Register a new user
2. Login and get token
3. Create a checking account
4. Create a savings account
5. Deposit money to checking account
6. Transfer between accounts
7. View transaction history

## 🎯 Common Use Cases

### Local Development
```bash
# Each service in separate terminal
cd auth-api && npm run dev
cd accounts-api && npm run dev
cd transactions-api && npm run dev
cd digitalbank-frontend && npm run dev
```

### Production-like Testing
```bash
docker-compose up -d
# Access at http://localhost:3000
```

### API Testing
- Import `api-collection.json` into Postman
- Or use curl commands from terminal

## 📚 Documentation Files

- `README.md` - Complete project documentation
- `CONTRIBUTING.md` - Contribution guidelines
- `QUICKSTART.md` - This file
- `api-collection.json` - Postman collection

## 💡 Tips

- Use Postman collection for easy API testing
- Check health endpoints first when debugging
- Use `make help` to see all available commands
- Keep Docker logs open when developing
- Test with different account types
- Always check transaction status

## 🆘 Getting Help

- Check logs: `docker-compose logs -f`
- Verify services: `docker-compose ps`
- Health checks: `curl http://localhost:300X/health`
- Database access: See Database Access section above

---

**Happy Banking! 🎉**
