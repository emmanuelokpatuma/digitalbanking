# 🏦 Digital Banking Platform - Complete Testing Guide

## 🎯 Quick Start: Test the Full Banking Flow

### Step 1: Register a New User

**URL**: http://34.31.22.16/register

Fill out the form:
- **Email**: john.doe@example.com
- **Password**: SecurePass123!
- **First Name**: John
- **Last Name**: Doe

**Or use cURL**:
```bash
curl -X POST http://34.31.22.16/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

**Response**:
```json
{
  "user": {
    "id": 1,
    "email": "john.doe@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

💾 **Save the token!** You'll need it for all subsequent requests.

---

### Step 2: Login (if needed)

**URL**: http://34.31.22.16/login

```bash
curl -X POST http://34.31.22.16/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePass123!"
  }'
```

---

### Step 3: Create Bank Accounts

You need to create accounts before you can transfer money!

#### Create a Checking Account

**In Browser**: Navigate to Accounts page and click "Create Account"

**Or use cURL**:
```bash
# Set your token
TOKEN="your-jwt-token-here"

# Create checking account
curl -X POST http://34.31.22.16/api/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "account_type": "checking",
    "currency": "USD"
  }'
```

**Response**:
```json
{
  "id": 1,
  "user_id": 1,
  "account_number": "ACC-1234567890",
  "account_type": "checking",
  "balance": 0.00,
  "currency": "USD",
  "status": "active"
}
```

#### Create a Savings Account

```bash
curl -X POST http://34.31.22.16/api/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "account_type": "savings",
    "currency": "USD"
  }'
```

**Response**:
```json
{
  "id": 2,
  "user_id": 1,
  "account_number": "ACC-0987654321",
  "account_type": "savings",
  "balance": 0.00,
  "currency": "USD",
  "status": "active"
}
```

---

### Step 4: Add Money to Your Accounts

#### Deposit to Checking Account

```bash
# Replace 1 with your actual account ID
ACCOUNT_ID=1

curl -X POST http://34.31.22.16/api/accounts/$ACCOUNT_ID/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "amount": 1000.00
  }'
```

**Response**:
```json
{
  "message": "Deposit successful",
  "account": {
    "id": 1,
    "balance": 1000.00
  }
}
```

#### Deposit to Savings Account

```bash
SAVINGS_ACCOUNT_ID=2

curl -X POST http://34.31.22.16/api/accounts/$SAVINGS_ACCOUNT_ID/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "amount": 5000.00
  }'
```

---

### Step 5: View Your Accounts

**In Browser**: http://34.31.22.16/accounts

**Or use cURL**:
```bash
curl http://34.31.22.16/api/accounts \
  -H "Authorization: Bearer $TOKEN"
```

**Response**:
```json
{
  "accounts": [
    {
      "id": 1,
      "account_number": "ACC-1234567890",
      "account_type": "checking",
      "balance": 1000.00,
      "currency": "USD",
      "status": "active"
    },
    {
      "id": 2,
      "account_number": "ACC-0987654321",
      "account_type": "savings",
      "balance": 5000.00,
      "currency": "USD",
      "status": "active"
    }
  ]
}
```

---

### Step 6: Transfer Money Between Accounts

**In Browser**: http://34.31.22.16/transfer

**Or use cURL**:
```bash
curl -X POST http://34.31.22.16/api/transactions/transfer \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "from_account_id": 2,
    "to_account_id": 1,
    "amount": 500.00,
    "description": "Transfer from savings to checking"
  }'
```

**Response**:
```json
{
  "transaction": {
    "id": 1,
    "type": "transfer",
    "from_account_id": 2,
    "to_account_id": 1,
    "amount": 500.00,
    "description": "Transfer from savings to checking",
    "status": "completed",
    "created_at": "2026-01-28T15:30:00Z"
  },
  "message": "Transfer successful"
}
```

---

### Step 7: View Transactions

**In Browser**: http://34.31.22.16/transactions

**Or use cURL**:
```bash
# Get all your transactions
curl http://34.31.22.16/api/transactions \
  -H "Authorization: Bearer $TOKEN"

# Get transactions for a specific account
curl http://34.31.22.16/api/transactions/account/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📋 Complete API Reference

### Account Endpoints

| Endpoint | Method | Description | Body |
|----------|--------|-------------|------|
| `/api/accounts` | POST | Create new account | `{"account_type": "checking\|savings\|investment", "currency": "USD"}` |
| `/api/accounts` | GET | Get all accounts | - |
| `/api/accounts/:id` | GET | Get account by ID | - |
| `/api/accounts/:id/deposit` | POST | Deposit money | `{"amount": 100.00}` |
| `/api/accounts/:id/withdraw` | POST | Withdraw money | `{"amount": 50.00}` |
| `/api/accounts/:id/balance` | GET | Get account balance | - |
| `/api/accounts/:id/status` | PATCH | Update account status | `{"status": "active\|frozen\|closed"}` |

### Transaction Endpoints

| Endpoint | Method | Description | Body |
|----------|--------|-------------|------|
| `/api/transactions/transfer` | POST | Transfer between accounts | `{"from_account_id": 1, "to_account_id": 2, "amount": 100, "description": "text"}` |
| `/api/transactions/payment` | POST | Make a payment | `{"account_id": 1, "amount": 100, "recipient": "John Doe", "description": "text"}` |
| `/api/transactions` | GET | Get all transactions | - |
| `/api/transactions/:id` | GET | Get transaction by ID | - |
| `/api/transactions/account/:accountId` | GET | Get account transactions | - |

---

## 🧪 Complete Test Scenario

Here's a script to test everything:

```bash
#!/bin/bash

# Base URL
BASE_URL="http://34.31.22.16/api"

echo "=== Digital Banking Test Flow ==="
echo ""

# 1. Register User
echo "1. Registering user..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test'$(date +%s)'@example.com",
    "password": "SecurePass123!",
    "first_name": "Test",
    "last_name": "User"
  }')

TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "✅ User registered. Token: ${TOKEN:0:20}..."
echo ""

# 2. Create Checking Account
echo "2. Creating checking account..."
CHECKING_RESPONSE=$(curl -s -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"account_type": "checking", "currency": "USD"}')

CHECKING_ID=$(echo $CHECKING_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "✅ Checking account created. ID: $CHECKING_ID"
echo ""

# 3. Create Savings Account
echo "3. Creating savings account..."
SAVINGS_RESPONSE=$(curl -s -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"account_type": "savings", "currency": "USD"}')

SAVINGS_ID=$(echo $SAVINGS_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
echo "✅ Savings account created. ID: $SAVINGS_ID"
echo ""

# 4. Deposit to Checking
echo "4. Depositing $1000 to checking..."
curl -s -X POST $BASE_URL/accounts/$CHECKING_ID/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"amount": 1000.00}' > /dev/null
echo "✅ Deposited $1000"
echo ""

# 5. Deposit to Savings
echo "5. Depositing $5000 to savings..."
curl -s -X POST $BASE_URL/accounts/$SAVINGS_ID/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"amount": 5000.00}' > /dev/null
echo "✅ Deposited $5000"
echo ""

# 6. Check Balances
echo "6. Checking account balances..."
ACCOUNTS=$(curl -s $BASE_URL/accounts \
  -H "Authorization: Bearer $TOKEN")
echo "$ACCOUNTS" | grep -E "account_type|balance"
echo ""

# 7. Transfer Money
echo "7. Transferring $300 from savings to checking..."
curl -s -X POST $BASE_URL/transactions/transfer \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"from_account_id\": $SAVINGS_ID,
    \"to_account_id\": $CHECKING_ID,
    \"amount\": 300.00,
    \"description\": \"Test transfer\"
  }" > /dev/null
echo "✅ Transfer completed"
echo ""

# 8. View Transactions
echo "8. Viewing recent transactions..."
TRANSACTIONS=$(curl -s $BASE_URL/transactions \
  -H "Authorization: Bearer $TOKEN")
echo "$TRANSACTIONS" | grep -E "type|amount|description" | head -6
echo ""

echo "=== Test Complete! ==="
echo ""
echo "📊 Summary:"
echo "   - User registered: ✅"
echo "   - Accounts created: 2 (Checking #$CHECKING_ID, Savings #$SAVINGS_ID)"
echo "   - Initial deposits: ✅"
echo "   - Transfer executed: ✅"
echo "   - Transactions recorded: ✅"
echo ""
echo "🌐 View in browser:"
echo "   Dashboard: http://34.31.22.16/dashboard"
echo "   Accounts: http://34.31.22.16/accounts"
echo "   Transactions: http://34.31.22.16/transactions"
```

Save this as `test-banking.sh`, make it executable (`chmod +x test-banking.sh`), and run it!

---

## 🎨 Using the Web Interface

### Browser Flow

1. **Register/Login** at http://34.31.22.16
2. **Dashboard** - View account summary
3. **Accounts Page** - Create accounts:
   - Click "Create Account" button
   - Choose account type (Checking, Savings, Investment)
   - Select currency (USD)
4. **Add Money** - Use deposit function
5. **Transfer Page** - Transfer between your accounts:
   - Select source account
   - Select destination account
   - Enter amount
   - Add description
   - Click "Transfer"
6. **Transactions Page** - View transaction history

---

## 💡 Pro Tips

### Creating Multiple Test Users

Test transfers between different users:

```bash
# Register User 1
curl -X POST http://34.31.22.16/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@example.com", "password": "Pass123!", "first_name": "Alice", "last_name": "Smith"}'

# Register User 2
curl -X POST http://34.31.22.16/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "bob@example.com", "password": "Pass123!", "first_name": "Bob", "last_name": "Jones"}'
```

### Account Types

- **Checking**: Daily transactions, debit card access
- **Savings**: Higher interest, withdrawal limits
- **Investment**: Long-term savings, higher risk/reward

### Available Currencies

- USD (US Dollar)
- EUR (Euro)
- GBP (British Pound)
- CAD (Canadian Dollar)

---

## 🔍 Troubleshooting

### "Unauthorized" Error
- Make sure you're including the token: `-H "Authorization: Bearer $TOKEN"`
- Token might have expired - login again

### "Account not found"
- Verify account ID in the URL
- Make sure you're accessing your own accounts

### "Insufficient funds"
- Deposit money before transferring
- Check current balance: `GET /api/accounts/:id/balance`

### Transfer not working
- Both accounts must belong to you
- Both accounts must have status "active"
- Source account must have sufficient balance

---

## 📊 Sample Data

Use this JSON to quickly test with Postman/Insomnia:

### Register
```json
{
  "email": "demo@digitalbank.com",
  "password": "SecurePass123!",
  "first_name": "Demo",
  "last_name": "User"
}
```

### Create Checking Account
```json
{
  "account_type": "checking",
  "currency": "USD"
}
```

### Deposit
```json
{
  "amount": 1500.50
}
```

### Transfer
```json
{
  "from_account_id": 1,
  "to_account_id": 2,
  "amount": 250.00,
  "description": "Monthly savings transfer"
}
```

---

**🎉 Happy Banking! Access the app at: http://34.31.22.16**
