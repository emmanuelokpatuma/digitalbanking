# 🌐 External Browser Access Guide

## 🎯 Single External IP for Everything!

**External IP**: `34.31.22.16`

All services are accessible via this single LoadBalancer IP using hostname-based routing.

---

## 📊 Monitoring & Management Dashboards

### Option 1: Using /etc/hosts (Recommended for Testing)

Add these lines to your `/etc/hosts` file:

```bash
# Digital Banking Platform Dashboards
34.31.22.16  grafana.digitalbank.local
34.31.22.16  prometheus.digitalbank.local
34.31.22.16  argocd.digitalbank.local
34.31.22.16  kibana.digitalbank.local
34.31.22.16  api.digitalbank.local
```

**On Linux/Mac**:
```bash
sudo nano /etc/hosts
# Or use this one-liner:
echo "34.31.22.16  grafana.digitalbank.local prometheus.digitalbank.local argocd.digitalbank.local kibana.digitalbank.local api.digitalbank.local" | sudo tee -a /etc/hosts
```

**On Windows**:
1. Open Notepad as Administrator
2. Open: `C:\Windows\System32\drivers\etc\hosts`
3. Add the lines above

### Option 2: Using curl with Host Header

```bash
curl -H "Host: grafana.digitalbank.local" http://34.31.22.16
```

---

## 🎛️ Dashboard Access URLs

| Dashboard | URL | Credentials |
|-----------|-----|-------------|
| **Grafana** | http://grafana.digitalbank.local | admin / admin123 |
| **Prometheus** | http://prometheus.digitalbank.local | None |
| **Kibana** | http://kibana.digitalbank.local | None (initializing) |
| **ArgoCD** | http://argocd.digitalbank.local | admin / PJm6W1MKJDOEv9en |

### 📈 Grafana (Dashboards)
```
URL: http://grafana.digitalbank.local
Username: admin
Password: admin123

Features:
- Pre-loaded Kubernetes dashboards
- Real-time cluster metrics
- Pod & node monitoring
- Custom dashboard creation
```

### 🔍 Prometheus (Metrics)
```
URL: http://prometheus.digitalbank.local
No authentication required

Features:
- PromQL query interface
- Metrics explorer
- Alert manager
- Target health status
```

### 📋 Kibana (Log Analytics)
```
URL: http://kibana.digitalbank.local
No authentication required
Status: Still initializing (takes 5-10 min)

First-time Setup:
1. Wait for Kibana to fully initialize
2. Go to Stack Management → Index Patterns
3. Create pattern: digitalbank-*
4. Select @timestamp as time field
5. Navigate to Discover to view logs
```

### 🔄 ArgoCD (GitOps)
```
URL: http://argocd.digitalbank.local
Username: admin
Password: PJm6W1MKJDOEv9en

Features:
- GitOps deployment management
- Application sync status
- Rollback capabilities
- Multi-cluster support
```

---

## 🚀 Application APIs

All APIs are accessible via the same external IP!

### Direct IP Access

**Base URL**: `http://34.31.22.16`

| API Endpoint | URL | Method | Description |
|-------------|-----|---------|-------------|
| Auth Health | http://34.31.22.16/api/auth/health | GET | Health check |
| Auth Register | http://34.31.22.16/api/auth/register | POST | Register user |
| Auth Login | http://34.31.22.16/api/auth/login | POST | Login |
| Accounts Health | http://34.31.22.16/api/accounts/health | GET | Health check |
| Accounts List | http://34.31.22.16/api/accounts | GET | Get accounts (auth required) |
| Transactions Health | http://34.31.22.16/api/transactions/health | GET | Health check |
| Transactions List | http://34.31.22.16/api/transactions | GET | Get transactions (auth required) |
| Frontend | http://34.31.22.16 | GET | React frontend |

### Using Custom Domain (with /etc/hosts)

Add to `/etc/hosts`:
```
34.31.22.16  api.digitalbank.local
```

Then access:
```
http://api.digitalbank.local/api/auth/health
http://api.digitalbank.local/api/accounts/health
http://api.digitalbank.local/api/transactions/health
```

---

## 🧪 Test the APIs

### Health Check
```bash
# Auth API
curl http://34.31.22.16/api/auth/health

# Accounts API
curl http://34.31.22.16/api/accounts/health

# Transactions API
curl http://34.31.22.16/api/transactions/health
```

### Register a User
```bash
curl -X POST http://34.31.22.16/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!",
    "name": "Test User"
  }'
```

### Login
```bash
curl -X POST http://34.31.22.16/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!"
  }'
```

### Access Protected Endpoints
```bash
# Get the token from login response, then:
TOKEN="your-jwt-token-here"

# Get accounts
curl http://34.31.22.16/api/accounts \
  -H "Authorization: Bearer $TOKEN"

# Get transactions
curl http://34.31.22.16/api/transactions \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🌍 Alternative: Legacy LoadBalancers

You also have individual LoadBalancers (can be removed to save costs):

| Service | External IP | Port |
|---------|-------------|------|
| Accounts API | 34.57.24.193 | 80 |
| Transactions API | 34.123.73.111 | 80 |

Direct access:
```bash
curl http://34.57.24.193/health
curl http://34.123.73.111/health
```

**💡 Recommendation**: Use the single Ingress IP (34.31.22.16) and delete the LoadBalancers to reduce costs:
```bash
kubectl delete svc accounts-api transactions-api -n digitalbank
```

---

## 🔒 Production DNS Setup (Optional)

For production, configure your DNS provider:

```
A Record: grafana.digitalbank.com → 34.31.22.16
A Record: prometheus.digitalbank.com → 34.31.22.16
A Record: argocd.digitalbank.com → 34.31.22.16
A Record: kibana.digitalbank.com → 34.31.22.16
A Record: api.digitalbank.com → 34.31.22.16
A Record: digitalbank.com → 34.31.22.16
```

---

## 📊 Complete Platform Overview

```
Single External IP: 34.31.22.16
         │
         ├─ http://grafana.digitalbank.local → Grafana Dashboard
         ├─ http://prometheus.digitalbank.local → Prometheus Metrics
         ├─ http://argocd.digitalbank.local → ArgoCD GitOps
         ├─ http://kibana.digitalbank.local → Kibana Logs
         │
         └─ http://34.31.22.16
             ├─ /api/auth/* → Auth API (3001)
             ├─ /api/accounts/* → Accounts API (3002)
             ├─ /api/transactions/* → Transactions API (3003)
             └─ /* → React Frontend (80)
```

---

## 🚨 Quick Access Commands

```bash
# Add all hosts at once (Linux/Mac)
cat << EOF | sudo tee -a /etc/hosts
34.31.22.16  grafana.digitalbank.local
34.31.22.16  prometheus.digitalbank.local
34.31.22.16  argocd.digitalbank.local
34.31.22.16  kibana.digitalbank.local
34.31.22.16  api.digitalbank.local
EOF

# Test all dashboards
curl -I http://grafana.digitalbank.local
curl -I http://prometheus.digitalbank.local
curl -I http://kibana.digitalbank.local
curl -I http://argocd.digitalbank.local

# Test all APIs
curl http://34.31.22.16/api/auth/health
curl http://34.31.22.16/api/accounts/health
curl http://34.31.22.16/api/transactions/health
```

---

**🎉 Everything is accessible from your browser at IP: 34.31.22.16**

Just add the hostnames to `/etc/hosts` and open in your browser!
