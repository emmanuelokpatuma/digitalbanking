# 🏦 Digital Banking Platform

A modern, cloud-native fintech microservices architecture built with Node.js, React, PostgreSQL, and Docker.

![Architecture](https://img.shields.io/badge/Architecture-Microservices-blue)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green)
![React](https://img.shields.io/badge/React-18.x-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)

## 🚀 Features

### 🔐 Authentication Service (auth-api)
- User registration and login
- JWT-based authentication
- Token refresh mechanism
- Secure password hashing with bcrypt
- Email validation

### 💰 Accounts Service (accounts-api)
- Create multiple bank accounts (checking, savings, investment)
- View account details and balances
- Deposit and withdraw funds
- Account status management
- Multi-currency support

### 💸 Transactions Service (transactions-api)
- Internal transfers between accounts
- Payment processing
- Transaction history
- Real-time balance updates
- Transaction rollback on failures

### 🎨 Frontend Application (digitalbank-frontend)
- Modern React-based UI
- Responsive design
- User dashboard with account overview
- Account management interface
- Transfer money interface
- Transaction history viewer
- Secure authentication flow

## 📋 Architecture

```
┌─────────────────────┐
│  digitalbank-       │
│  frontend (React)   │
│  Port: 3000         │
└──────────┬──────────┘
           │
           ├─────────────────┬─────────────────┬──────────────────┐
           │                 │                 │                  │
           ▼                 ▼                 ▼                  ▼
    ┌──────────┐      ┌──────────┐     ┌──────────┐      ┌──────────┐
    │ auth-api │      │accounts- │     │transact- │      │PostgreSQL│
    │ Port:3001│      │api 3002  │     │ions 3003 │      │Databases │
    └────┬─────┘      └────┬─────┘     └────┬─────┘      └──────────┘
         │                 │                 │
         ▼                 ▼                 ▼
    ┌──────────┐      ┌──────────┐     ┌──────────┐
    │ auth-db  │      │accounts- │     │transact- │
    │ :5432    │      │db :5433  │     │ions-db   │
    └──────────┘      └──────────┘     │ :5434    │
                                        └──────────┘
```

## 🛠️ Tech Stack

### Backend Services
- **Runtime**: Node.js 18
- **Framework**: Express.js
- **Database**: PostgreSQL 15
- **Authentication**: JWT (jsonwebtoken)
- **Password Hashing**: bcryptjs
- **Validation**: express-validator
- **HTTP Client**: axios
- **Security**: helmet, cors

### Frontend
- **Framework**: React 18
- **Build Tool**: Vite
- **Routing**: React Router v6
- **HTTP Client**: axios
- **Styling**: Custom CSS

### DevOps
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Web Server**: Nginx (for frontend)

## 📦 Project Structure

```
digitalbanking/
├── auth-api/
│   ├── src/
│   │   ├── config/
│   │   │   └── database.js
│   │   ├── controllers/
│   │   │   └── auth.controller.js
│   │   ├── middleware/
│   │   │   └── auth.middleware.js
│   │   ├── routes/
│   │   │   └── auth.routes.js
│   │   └── server.js
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
├── accounts-api/
│   ├── src/
│   │   ├── config/
│   │   │   └── database.js
│   │   ├── controllers/
│   │   │   └── account.controller.js
│   │   ├── middleware/
│   │   │   └── auth.middleware.js
│   │   ├── routes/
│   │   │   └── account.routes.js
│   │   └── server.js
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
├── transactions-api/
│   ├── src/
│   │   ├── config/
│   │   │   └── database.js
│   │   ├── controllers/
│   │   │   └── transaction.controller.js
│   │   ├── middleware/
│   │   │   └── auth.middleware.js
│   │   ├── routes/
│   │   │   └── transaction.routes.js
│   │   └── server.js
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
├── digitalbank-frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── Navigation.jsx
│   │   │   └── PrivateRoute.jsx
│   │   ├── contexts/
│   │   │   └── AuthContext.jsx
│   │   ├── pages/
│   │   │   ├── Login.jsx
│   │   │   ├── Register.jsx
│   │   │   ├── Dashboard.jsx
│   │   │   ├── Accounts.jsx
│   │   │   ├── Transactions.jsx
│   │   │   └── Transfer.jsx
│   │   ├── App.jsx
│   │   ├── main.jsx
│   │   └── index.css
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   └── .env.example
├── docker-compose.yml
└── README.md
```

## 🚀 Getting Started

### Prerequisites
- Docker (version 20.x or higher)
- Docker Compose (version 2.x or higher)
- Node.js 18.x (for local development)

### Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd digitalbanking
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - Frontend: http://localhost:3000
   - Auth API: http://localhost:3001
   - Accounts API: http://localhost:3002
   - Transactions API: http://localhost:3003

4. **Stop all services**
   ```bash
   docker-compose down
   ```

5. **Stop and remove volumes (clean slate)**
   ```bash
   docker-compose down -v
   ```

### Local Development Setup

#### Auth API
```bash
cd auth-api
cp .env.example .env
npm install
npm run dev
```

#### Accounts API
```bash
cd accounts-api
cp .env.example .env
npm install
npm run dev
```

#### Transactions API
```bash
cd transactions-api
cp .env.example .env
npm install
npm run dev
```

#### Frontend
```bash
cd digitalbank-frontend
cp .env.example .env
npm install
npm run dev
```

## 📚 API Documentation

### Auth API (Port 3001)

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123",
  "first_name": "John",
  "last_name": "Doe"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

#### Verify Token
```http
GET /api/auth/verify
Authorization: Bearer <token>
```

### Accounts API (Port 3002)

#### Create Account
```http
POST /api/accounts
Authorization: Bearer <token>
Content-Type: application/json

{
  "account_type": "checking",
  "currency": "USD"
}
```

#### Get All Accounts
```http
GET /api/accounts
Authorization: Bearer <token>
```

#### Get Account by ID
```http
GET /api/accounts/:accountId
Authorization: Bearer <token>
```

#### Deposit
```http
POST /api/accounts/:accountId/deposit
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 100.00
}
```

#### Withdraw
```http
POST /api/accounts/:accountId/withdraw
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 50.00
}
```

### Transactions API (Port 3003)

#### Transfer Money
```http
POST /api/transactions/transfer
Authorization: Bearer <token>
Content-Type: application/json

{
  "from_account_id": 1,
  "to_account_id": 2,
  "amount": 100.00,
  "description": "Payment for services"
}
```

#### Make Payment
```http
POST /api/transactions/payment
Authorization: Bearer <token>
Content-Type: application/json

{
  "account_id": 1,
  "amount": 50.00,
  "recipient": "Utility Company",
  "description": "Monthly bill"
}
```

#### Get All Transactions
```http
GET /api/transactions?limit=50&offset=0
Authorization: Bearer <token>
```

#### Get Transaction by ID
```http
GET /api/transactions/:transactionId
Authorization: Bearer <token>
```

## 🔒 Security Features

- **Password Security**: Passwords are hashed using bcrypt with salt rounds
- **JWT Authentication**: Stateless authentication with expiring tokens
- **CORS Protection**: Configured CORS headers for API security
- **Helmet.js**: Security headers for Express applications
- **Input Validation**: Request validation using express-validator
- **SQL Injection Protection**: Parameterized queries with pg library
- **Environment Variables**: Sensitive data stored in environment variables

## 🧪 Testing

Each service can be tested individually:

```bash
# Auth API
cd auth-api
npm test

# Accounts API
cd accounts-api
npm test

# Transactions API
cd transactions-api
npm test
```

## 🔧 Configuration

### Environment Variables

#### Auth API
- `PORT`: Server port (default: 3001)
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: Secret key for JWT signing
- `JWT_EXPIRES_IN`: Token expiration time
- `NODE_ENV`: Environment (development/production)

#### Accounts API
- `PORT`: Server port (default: 3002)
- `DATABASE_URL`: PostgreSQL connection string
- `AUTH_API_URL`: URL of the auth service
- `NODE_ENV`: Environment

#### Transactions API
- `PORT`: Server port (default: 3003)
- `DATABASE_URL`: PostgreSQL connection string
- `AUTH_API_URL`: URL of the auth service
- `ACCOUNTS_API_URL`: URL of the accounts service
- `NODE_ENV`: Environment

#### Frontend
- `VITE_AUTH_API_URL`: Auth API endpoint
- `VITE_ACCOUNTS_API_URL`: Accounts API endpoint
- `VITE_TRANSACTIONS_API_URL`: Transactions API endpoint

## 🐳 Docker Commands

```bash
# Build all services
docker-compose build

# Start services in background
docker-compose up -d

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f auth-api

# Restart a service
docker-compose restart auth-api

# Stop all services
docker-compose down

# Remove all data
docker-compose down -v
```

## 📊 Database Schema

### Users Table (auth-db)
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP,
  is_active BOOLEAN DEFAULT true
);
```

### Accounts Table (accounts-db)
```sql
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  account_number VARCHAR(20) UNIQUE NOT NULL,
  account_type VARCHAR(50) NOT NULL,
  balance DECIMAL(15, 2) DEFAULT 0.00,
  currency VARCHAR(3) DEFAULT 'USD',
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Transactions Table (transactions-db)
```sql
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  transaction_id VARCHAR(50) UNIQUE NOT NULL,
  user_id INTEGER NOT NULL,
  from_account_id INTEGER,
  to_account_id INTEGER,
  transaction_type VARCHAR(50) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  status VARCHAR(20) DEFAULT 'pending',
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP
);
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the ISC License.

## 🙏 Acknowledgments

- Built with modern microservices architecture principles
- Follows RESTful API design patterns
- Implements industry-standard security practices
- Uses containerization for easy deployment

## 📞 Support

For issues, questions, or contributions, please open an issue on the repository.

---

**Built with ❤️ for the modern fintech ecosystem**
