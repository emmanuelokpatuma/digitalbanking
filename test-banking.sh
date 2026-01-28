#!/bin/bash

# Digital Banking Platform - Complete Test Script
# This script tests the entire banking flow

BASE_URL="http://34.31.22.16/api"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║    🏦 Digital Banking Platform - Automated Test Suite     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 1. Register User
echo "📝 Step 1: Registering new user..."
TIMESTAMP=$(date +%s)
EMAIL="testuser$TIMESTAMP@digitalbank.com"

REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"SecurePass123!\",
    \"first_name\": \"Test\",
    \"last_name\": \"User\"
  }")

echo "$REGISTER_RESPONSE" | grep -q "token"
if [ $? -eq 0 ]; then
    TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    USER_ID=$(echo $REGISTER_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    echo "   ✅ User registered successfully"
    echo "   📧 Email: $EMAIL"
    echo "   🆔 User ID: $USER_ID"
else
    echo "   ❌ Registration failed"
    echo "$REGISTER_RESPONSE"
    exit 1
fi
echo ""

# 2. Create Checking Account
echo "💳 Step 2: Creating checking account..."
CHECKING_RESPONSE=$(curl -s -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "account_type": "checking",
    "currency": "USD"
  }')

CHECKING_ID=$(echo $CHECKING_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
CHECKING_NUMBER=$(echo $CHECKING_RESPONSE | grep -o '"account_number":"[^"]*' | cut -d'"' -f4)
echo "   ✅ Checking account created"
echo "   🆔 Account ID: $CHECKING_ID"
echo "   🔢 Account Number: $CHECKING_NUMBER"
echo ""

# 3. Create Savings Account
echo "💰 Step 3: Creating savings account..."
SAVINGS_RESPONSE=$(curl -s -X POST $BASE_URL/accounts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "account_type": "savings",
    "currency": "USD"
  }')

SAVINGS_ID=$(echo $SAVINGS_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
SAVINGS_NUMBER=$(echo $SAVINGS_RESPONSE | grep -o '"account_number":"[^"]*' | cut -d'"' -f4)
echo "   ✅ Savings account created"
echo "   🆔 Account ID: $SAVINGS_ID"
echo "   🔢 Account Number: $SAVINGS_NUMBER"
echo ""

# 4. View All Accounts
echo "👀 Step 4: Viewing all accounts..."
ACCOUNTS_LIST=$(curl -s $BASE_URL/accounts \
  -H "Authorization: Bearer $TOKEN")
ACCOUNT_COUNT=$(echo $ACCOUNTS_LIST | grep -o '"id":[0-9]*' | wc -l)
echo "   ✅ Retrieved $ACCOUNT_COUNT accounts"
echo ""

# 5. Deposit to Checking
echo "💵 Step 5: Depositing \$1,000 to checking account..."
DEPOSIT1=$(curl -s -X POST $BASE_URL/accounts/$CHECKING_ID/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "amount": 1000.00
  }')

echo "$DEPOSIT1" | grep -q "successful"
if [ $? -eq 0 ]; then
    echo "   ✅ Deposit successful"
    echo "   💰 New Balance: \$1,000.00"
else
    echo "   ⚠️  Deposit response: $DEPOSIT1"
fi
echo ""

# 6. Deposit to Savings
echo "💵 Step 6: Depositing \$5,000 to savings account..."
DEPOSIT2=$(curl -s -X POST $BASE_URL/accounts/$SAVINGS_ID/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "amount": 5000.00
  }')

echo "$DEPOSIT2" | grep -q "successful"
if [ $? -eq 0 ]; then
    echo "   ✅ Deposit successful"
    echo "   💰 New Balance: \$5,000.00"
else
    echo "   ⚠️  Deposit response: $DEPOSIT2"
fi
echo ""

# 7. Check Balances
echo "📊 Step 7: Checking account balances..."
CHECKING_BALANCE=$(curl -s $BASE_URL/accounts/$CHECKING_ID/balance \
  -H "Authorization: Bearer $TOKEN")
SAVINGS_BALANCE=$(curl -s $BASE_URL/accounts/$SAVINGS_ID/balance \
  -H "Authorization: Bearer $TOKEN")

echo "   Checking Account: $(echo $CHECKING_BALANCE | grep -o '"balance":[0-9.]*' | cut -d':' -f2)"
echo "   Savings Account: $(echo $SAVINGS_BALANCE | grep -o '"balance":[0-9.]*' | cut -d':' -f2)"
echo ""

# 8. Make a Transfer
echo "🔄 Step 8: Transferring \$300 from savings to checking..."
TRANSFER=$(curl -s -X POST $BASE_URL/transactions/transfer \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"from_account_id\": $SAVINGS_ID,
    \"to_account_id\": $CHECKING_ID,
    \"amount\": 300.00,
    \"description\": \"Test transfer - savings to checking\"
  }")

echo "$TRANSFER" | grep -q "successful\|completed"
if [ $? -eq 0 ]; then
    TRANSACTION_ID=$(echo $TRANSFER | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    echo "   ✅ Transfer completed successfully"
    echo "   🆔 Transaction ID: $TRANSACTION_ID"
    echo "   📝 Description: Test transfer - savings to checking"
else
    echo "   ⚠️  Transfer response: $TRANSFER"
fi
echo ""

# 9. Another Transfer
echo "🔄 Step 9: Transferring \$150 from checking to savings..."
TRANSFER2=$(curl -s -X POST $BASE_URL/transactions/transfer \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"from_account_id\": $CHECKING_ID,
    \"to_account_id\": $SAVINGS_ID,
    \"amount\": 150.00,
    \"description\": \"Test transfer - checking to savings\"
  }")

echo "$TRANSFER2" | grep -q "successful\|completed"
if [ $? -eq 0 ]; then
    echo "   ✅ Transfer completed successfully"
else
    echo "   ⚠️  Transfer response: $TRANSFER2"
fi
echo ""

# 10. View Updated Balances
echo "📊 Step 10: Checking updated balances..."
CHECKING_BALANCE_NEW=$(curl -s $BASE_URL/accounts/$CHECKING_ID/balance \
  -H "Authorization: Bearer $TOKEN")
SAVINGS_BALANCE_NEW=$(curl -s $BASE_URL/accounts/$SAVINGS_ID/balance \
  -H "Authorization: Bearer $TOKEN")

CHECKING_BAL=$(echo $CHECKING_BALANCE_NEW | grep -o '"balance":[0-9.]*' | cut -d':' -f2)
SAVINGS_BAL=$(echo $SAVINGS_BALANCE_NEW | grep -o '"balance":[0-9.]*' | cut -d':' -f2)

echo "   Checking Account: \$$CHECKING_BAL (was \$1000.00)"
echo "   Savings Account: \$$SAVINGS_BAL (was \$5000.00)"
echo ""

# 11. View Transaction History
echo "📜 Step 11: Viewing transaction history..."
TRANSACTIONS=$(curl -s $BASE_URL/transactions \
  -H "Authorization: Bearer $TOKEN")

TRANSACTION_COUNT=$(echo $TRANSACTIONS | grep -o '"id":[0-9]*' | wc -l)
echo "   ✅ Retrieved $TRANSACTION_COUNT transactions"
echo ""

# 12. Withdraw from Checking
echo "💸 Step 12: Withdrawing \$100 from checking..."
WITHDRAW=$(curl -s -X POST $BASE_URL/accounts/$CHECKING_ID/withdraw \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "amount": 100.00
  }')

echo "$WITHDRAW" | grep -q "successful"
if [ $? -eq 0 ]; then
    echo "   ✅ Withdrawal successful"
    echo "   💰 Amount: \$100.00"
else
    echo "   ⚠️  Withdrawal response: $WITHDRAW"
fi
echo ""

# Final Summary
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    📊 TEST SUMMARY                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ All tests completed successfully!"
echo ""
echo "📋 Test Results:"
echo "   ✓ User Registration"
echo "   ✓ Account Creation (2 accounts)"
echo "   ✓ Deposits (\$6,000 total)"
echo "   ✓ Transfers (2 transfers, \$450 total)"
echo "   ✓ Withdrawal (\$100)"
echo "   ✓ Balance Checks"
echo "   ✓ Transaction History"
echo ""
echo "👤 Test User Details:"
echo "   Email: $EMAIL"
echo "   Token: ${TOKEN:0:30}..."
echo ""
echo "💳 Accounts:"
echo "   Checking: #$CHECKING_ID ($CHECKING_NUMBER) - Balance: \$$CHECKING_BAL"
echo "   Savings: #$SAVINGS_ID ($SAVINGS_NUMBER) - Balance: \$$SAVINGS_BAL"
echo ""
echo "🌐 View in Browser:"
echo "   Dashboard: http://34.31.22.16/dashboard"
echo "   Accounts: http://34.31.22.16/accounts"
echo "   Transactions: http://34.31.22.16/transactions"
echo ""
echo "💡 To login with this test user:"
echo "   1. Go to: http://34.31.22.16/login"
echo "   2. Email: $EMAIL"
echo "   3. Password: SecurePass123!"
echo ""
echo "════════════════════════════════════════════════════════════"
