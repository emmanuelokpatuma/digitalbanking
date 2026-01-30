# 🎯 Digital Banking Platform - Complete Access Guide

## 🌐 Main Application URL

**Access everything at**: http://34.31.22.16

---

## ✅ Understanding the Setup

### Why You're Getting "Cannot GET /register"

The APIs are **backend services** - they don't serve HTML pages! 

- ❌ **Wrong**: Accessing http://34.31.22.16/api/auth/register in browser → "Cannot GET /register"
- ✅ **Correct**: The React frontend at http://34.31.22.16/register handles the UI

**The APIs only accept JSON requests**, not browser GET requests for pages!

---

## 📱 Frontend Pages (Access in Browser)

Open these URLs in your browser:

| Page | URL | Description |
|------|-----|-------------|
| **Home** | http://34.31.22.16 | Redirects to dashboard or login |
| **Login** | http://34.31.22.16/login | User login page |
| **Register** | http://34.31.22.16/register | New user registration |
| **Dashboard** | http://34.31.22.16/dashboard | Main dashboard (requires login) |
| **Accounts** | http://34.31.22.16/accounts | View bank accounts (requires login) |
| **Transactions** | http://34.31.22.16/transactions | View transactions (requires login) |
| **Transfer** | http://34.31.22.16/transfer | Make transfers (requires login) |

### How It Works:
1. Frontend (React) runs at http://34.31.22.16
2. When you visit /register, React shows the register form
3. When you submit the form, React calls the backend API: POST /api/auth/register
4. The API returns JSON (not HTML)

---

## 🔌 Backend API Endpoints (JSON Only)

These are for programmatic access (curl, Postman, frontend JS):

### Auth API (Port 3001)
```bash
# Register a new user (POST with JSON)
curl -X POST http://34.31.22.16/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe"
  }'

# Login (POST with JSON)
curl -X POST http://34.31.22.16/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'

# Health check (GET - only endpoint that returns JSON without auth)
curl http://34.31.22.16/api/auth/health
```

### Accounts API (Port 3002)
```bash
# Health check
curl http://34.31.22.16/api/accounts/health

# Get accounts (requires JWT token from login)
curl http://34.31.22.16/api/accounts \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

### Transactions API (Port 3003)
```bash
# Health check
curl http://34.31.22.16/api/transactions/health

# Get transactions (requires JWT token)
curl http://34.31.22.16/api/transactions \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

---

## 🚨 LoadBalancers vs Ingress - The Issue

### Current Problem:

You have **TWO** ways to access the APIs (wasteful!):

1. **✅ Ingress** (Recommended): http://34.31.22.16 → Routes to all services
2. **⚠️ LoadBalancers** (Legacy/Wasteful):
   - http://34.57.24.193 → Accounts API
   - http://34.123.73.111 → Transactions API

### Why LoadBalancers Exist:

These were created from an **old deployment manifest** in the `digitalbank` namespace (not `digitalbank-apps`). They're now **redundant** because we have Ingress!

### Cost Impact:

- **Each LoadBalancer**: ~$20-30/month
- **Ingress (1 LoadBalancer)**: ~$20-30/month total
- **Wasting**: ~$40-60/month on duplicate LoadBalancers! 💸

### Solution: Delete Legacy LoadBalancers

```bash
# Remove the old namespace with LoadBalancers
kubectl delete namespace digitalbank

# Or just delete the LoadBalancer services
kubectl delete svc accounts-api transactions-api -n digitalbank
```

**After deletion**, everything will still work via Ingress at http://34.31.22.16 ✅

---

## 🎯 Recommended Architecture

```
┌─────────────────────────────────────────────┐
│  Single External IP: 34.31.22.16           │
│  (Nginx Ingress LoadBalancer)              │
└──────────────┬──────────────────────────────┘
               │
               ├─ /register → Frontend (React page)
               ├─ /login → Frontend (React page)
               ├─ /dashboard → Frontend (React page)
               │
               ├─ /api/auth/* → Auth API (JSON responses)
               ├─ /api/accounts/* → Accounts API (JSON)
               └─ /api/transactions/* → Transactions API (JSON)
```

**No need for individual LoadBalancers!**

---

## 🧪 Complete User Flow Example

### 1. Open Frontend in Browser
```
http://34.31.22.16/register
```

### 2. Fill Out the Registration Form
The React app shows a form with fields:
- Email
- Password
- First Name
- Last Name

### 3. Submit the Form
React sends this request **behind the scenes**:
```bash
POST http://34.31.22.16/api/auth/register
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "MyPassword123!",
  "first_name": "New",
  "last_name": "User"
}
```

### 4. API Returns JSON
```json
{
  "user": {
    "id": 1,
    "email": "newuser@example.com",
    "first_name": "New",
    "last_name": "User"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 5. React Stores Token & Redirects
- Token saved in localStorage
- User redirected to /dashboard
- All future API calls include: `Authorization: Bearer {token}`

---

## 🔍 Debugging Tips

### Check if Frontend is Working
```bash
curl http://34.31.22.16/register
# Should return HTML with <div id="root"></div>
```

### Check if API is Working
```bash
curl http://34.31.22.16/api/auth/health
# Should return: {"status":"healthy","service":"auth-api"}
```

### Check Ingress Routing
```bash
kubectl describe ingress digitalbank-ingress -n digitalbank-apps
```

### View API Logs
```bash
kubectl logs -n digitalbank-apps -l app=auth-api --tail=50
kubectl logs -n digitalbank-apps -l app=accounts-api --tail=50
kubectl logs -n digitalbank-apps -l app=transactions-api --tail=50
```

---

## 🧹 Cleanup Redundant Resources

### Remove Legacy LoadBalancers
```bash
# Check what's in the old namespace
kubectl get all -n digitalbank

# Delete the entire namespace (if it's all legacy)
kubectl delete namespace digitalbank

# Verify only Ingress remains
kubectl get svc --all-namespaces | grep LoadBalancer
# Should only show: nginx-ingress-ingress-nginx-controller
```

### Result After Cleanup:
- ✅ Single external IP: 34.31.22.16
- ✅ All services accessible via Ingress
- ✅ Cost savings: ~$40-60/month
- ✅ Simplified architecture

---

## 📊 Current Platform Status

| Component | Type | External Access | Status |
|-----------|------|-----------------|--------|
| Frontend | ClusterIP + Ingress | http://34.31.22.16 | ✅ Working |
| Auth API | ClusterIP + Ingress | http://34.31.22.16/api/auth/* | ✅ Working |
| Accounts API | ClusterIP + Ingress | http://34.31.22.16/api/accounts/* | ✅ Working |
| Transactions API | ClusterIP + Ingress | http://34.31.22.16/api/transactions/* | ✅ Working |
| ~~Accounts LB~~ | ~~LoadBalancer~~ | ~~http://34.57.24.193~~ | ⚠️ Delete (redundant) |
| ~~Transactions LB~~ | ~~LoadBalancer~~ | ~~http://34.123.73.111~~ | ⚠️ Delete (redundant) |

---

## 🎉 Quick Start

1. **Open in browser**: http://34.31.22.16/register
2. **Create an account** using the form
3. **Login** at http://34.31.22.16/login
4. **Explore** the dashboard, accounts, transactions

**That's it!** No need to access APIs directly unless you're developing.

---

## ❓ FAQ

**Q: Why can't I access /register in the API URL?**  
A: Because `/register` is a **frontend route** (React page), not an API endpoint. The API endpoint is `/api/auth/register` and only accepts POST requests with JSON.

**Q: How do I test the API?**  
A: Use curl, Postman, or the frontend. APIs don't serve HTML pages.

**Q: Why do I have multiple LoadBalancers?**  
A: Legacy mistake. Delete the ones in the `digitalbank` namespace. Only the Ingress LoadBalancer is needed.

**Q: Will deleting LoadBalancers break anything?**  
A: No! Everything routes through Ingress at 34.31.22.16. The LoadBalancers are duplicates.

---

**🎯 Main URL**: http://34.31.22.16  
**✅ All pages and APIs accessible via single Ingress!**
