# Service Access URLs - Digital Banking Platform

**Generated**: January 31, 2026  
**Cluster**: digitalbank-gke  
**Project**: charged-thought-485008-q7

---

## Quick Access Dashboard

### 🌐 Main Application
| Service | URL | Purpose |
|---------|-----|---------|
| **Digital Banking Frontend** | http://34.31.22.16 | Main web application |

### 🔧 APIs (Backend Services)
| Service | URL | Purpose |
|---------|-----|---------|
| **Auth API** | http://34.31.22.16/api/auth | Authentication & login |
| **Accounts API** | http://34.31.22.16/api/accounts | Bank account management |
| **Transactions API** | http://34.31.22.16/api/transactions | Payments & transfers |

### 📊 Monitoring & Observability
| Service | URL | Port | Purpose | Status |
|---------|-----|------|---------|--------|
| **Grafana** | http://136.111.5.250 | 80 | Metrics dashboards | ✅ Working |
| **Prometheus** | http://34.71.18.248:9090 | 9090 | Metrics database & query | ✅ Working |
| **Kibana (Demo)** ⭐ | http://34.63.246.97:5601 | 5601 | Log search & analysis (USE THIS) | ✅ Working |
| **Kibana (ELK Demo)** | http://34.44.185.11:5601 | 5601 | Alternative ELK instance | ✅ Working |
| ~~**Kibana (Primary)**~~ | ~~http://34.173.39.60:5601~~ | ~~5601~~ | ~~Currently unavailable~~ | ❌ Down (Elasticsearch connection issue) |

### 🚀 DevOps Tools
| Service | URL | Port | Purpose |
|---------|-----|------|---------|
| **ArgoCD** | http://35.188.11.8 | 80 | GitOps deployment UI |
| **Jenkins** | http://34.29.9.149 | 80 | CI/CD pipeline |

---

## Detailed Access Information

### 1. Digital Banking Application

#### Frontend (Web Interface)
```
URL: http://34.31.22.16
Type: React Single Page Application
Namespace: digitalbank-apps
```

**What you'll see**: The main banking web interface where users can log in, view accounts, and make transactions.

---

#### Auth API (Authentication)
```
Base URL: http://34.31.22.16/api/auth
Endpoints:
  - POST /api/auth/register    (Create new user)
  - POST /api/auth/login       (User login)
  - POST /api/auth/logout      (User logout)
  - GET  /api/auth/validate    (Validate token)

Namespace: digitalbank-apps
Service Port: 3001
```

**Test it**:
```bash
curl http://34.31.22.16/api/auth/health
```

---

#### Accounts API (Bank Accounts)
```
Base URL: http://34.31.22.16/api/accounts
Endpoints:
  - GET    /api/accounts           (List all accounts)
  - POST   /api/accounts           (Create account)
  - GET    /api/accounts/:id       (Get account details)
  - PUT    /api/accounts/:id       (Update account)
  - DELETE /api/accounts/:id       (Delete account)

Namespace: digitalbank-apps
Service Port: 3002
```

**Test it**:
```bash
curl http://34.31.22.16/api/accounts/health
```

---

#### Transactions API (Payments)
```
Base URL: http://34.31.22.16/api/transactions
Endpoints:
  - GET  /api/transactions         (List transactions)
  - POST /api/transactions         (Create transaction)
  - GET  /api/transactions/:id     (Get transaction details)
  - POST /api/transactions/transfer (Transfer money)

Namespace: digitalbank-apps
Service Port: 3003
```

**Test it**:
```bash
curl http://34.31.22.16/api/transactions/health
```

---

### 2. Grafana (Monitoring Dashboards)

```
URL: http://136.111.5.250
Port: 80
Namespace: digitalbank-monitoring
Type: LoadBalancer

Default Credentials:
  Username: admin
  Password: (Check with command below)
```

**Get Grafana Password**:
```powershell
kubectl get secret -n digitalbank-monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

**What you'll see**: 
- Pre-built dashboards for Kubernetes monitoring
- Node resource usage (CPU, memory, disk)
- Pod metrics
- Custom application metrics
- Alert status

**Alternative Access via Ingress**:
```
http://34.31.22.16/grafana
(with hostname: grafana.digitalbank.local)
```

---

### 3. Prometheus (Metrics Database)

```
URL: http://34.71.18.248:9090
Port: 9090
Namespace: digitalbank-monitoring
Type: LoadBalancer

Web UI: http://34.71.18.248:9090
API: http://34.71.18.248:9090/api/v1/query
```

**What you'll see**:
- PromQL query interface
- Metrics explorer
- Target status (all scraped endpoints)
- Alert rules
- Service discovery

**Example Queries**:
```
# CPU usage per pod
container_cpu_usage_seconds_total

# Memory usage
container_memory_usage_bytes

# API request rate
http_requests_total
```

**Alternative Access via Ingress**:
```
http://34.31.22.16/prometheus
(with hostname: prometheus.digitalbank.local)
```

---

### 4. Kibana (Log Analysis)

#### ⭐ Recommended: Kibana Demo (Working)
```
URL: http://34.63.246.97:5601
Port: 5601
Namespace: logging
Type: LoadBalancer
Status: ✅ WORKING

Direct Access: http://34.63.246.97:5601
```

#### Alternative: ELK Demo Kibana (Working)
```
URL: http://34.44.185.11:5601
Port: 5601
Namespace: elk-demo
Type: LoadBalancer
Status: ✅ WORKING

Direct Access: http://34.44.185.11:5601
```

#### ❌ Primary Kibana Instance (Currently Down)
```
URL: http://34.173.39.60:5601 (DO NOT USE)
Port: 5601
Namespace: logging
Status: ❌ Cannot connect to Elasticsearch
Issue: socket hang up errors to Elasticsearch backend
```

**What you'll see**:
- Elasticsearch data visualization
- Log search and filtering
- Index patterns for different namespaces
- Saved searches and dashboards
- Real-time log tailing

**Useful Searches**:
```
# All logs from your apps
kubernetes.namespace: "digitalbank-apps"

# Auth API logs
kubernetes.container.name: "auth-api"

# Error logs only
log.level: "error"

# Last 15 minutes
@timestamp >= now-15m
```

**Alternative Access via Ingress**:
```
http://34.31.22.16/kibana
(with hostname: kibana.digitalbank.local)
```

---

### 5. ArgoCD (GitOps Continuous Delivery)

```
URL: http://35.188.11.8
HTTPS: https://35.188.11.8
Port: 80 (HTTP), 443 (HTTPS)
Namespace: argocd
Type: LoadBalancer

Default Username: admin
```

**Get ArgoCD Password**:
```powershell
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

**What you'll see**:
- Application deployment status
- Git repository sync status
- Kubernetes resource health
- Deployment history and rollback options
- Live manifest comparison

**CLI Access**:
```bash
argocd login 35.188.11.8
argocd app list
argocd app get digitalbank
```

**Alternative Access via Ingress**:
```
http://34.31.22.16/argocd
(with hostname: argocd.digitalbank.local)
```

---

### 6. Jenkins (CI/CD Pipeline)

```
URL: http://34.29.9.149
Port: 80 (Web UI), 50000 (Agent connection)
Namespace: jenkins
Type: LoadBalancer

Web Interface: http://34.29.9.149
Agent Port: 50000
```

**Get Jenkins Password**:
```powershell
kubectl exec -n jenkins $(kubectl get pods -n jenkins -l app.kubernetes.io/instance=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /run/secrets/additional/chart-admin-password
```

**What you'll see**:
- Build pipelines
- Job execution history
- Build artifacts
- Pipeline stages and logs
- Integrated SCM (Git) triggers

**Alternative Access via Ingress**:
```
http://34.31.22.16/jenkins
```

---

## Network Architecture Diagram

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────┐
│  NGINX Ingress Controller (34.31.22.16)         │
│  LoadBalancer: ingress-nginx                     │
└─────────────────────────────────────────────────┘
    │
    ├─► /                      → digitalbank-frontend (React App)
    │
    ├─► /api/auth/*            → auth-api:3001
    │
    ├─► /api/accounts/*        → accounts-api:3002
    │
    ├─► /api/transactions/*    → transactions-api:3003
    │
    ├─► /grafana/*             → grafana.digitalbank.local
    │
    ├─► /prometheus/*          → prometheus.digitalbank.local
    │
    ├─► /kibana/*              → kibana.digitalbank.local
    │
    ├─► /argocd/*              → argocd.digitalbank.local
    │
    └─► /jenkins/*             → jenkins

┌─────────────────────────────────────────────────┐
│  Direct LoadBalancer Services (Dedicated IPs)   │
├─────────────────────────────────────────────────┤
│  • Grafana:     136.111.5.250:80                │
│  • Prometheus:  34.71.18.248:9090               │
│  • Kibana:      34.173.39.60:5601               │
│  • ArgoCD:      35.188.11.8:80                  │
│  • Jenkins:     34.29.9.149:80                  │
└─────────────────────────────────────────────────┘
```

---

## Complete IP Address Summary

| Service | External IP | Port | Access Method |
|---------|-------------|------|---------------|
| **NGINX Ingress** | **34.31.22.16** | 80, 443 | Shared entry point |
| Grafana | 136.111.5.250 | 80 | Direct LoadBalancer |
| Prometheus | 34.71.18.248 | 9090 | Direct LoadBalancer |
| Kibana (Primary) | 34.173.39.60 | 5601 | Direct LoadBalancer |
| Kibana (Demo) | 34.63.246.97 | 5601 | Direct LoadBalancer |
| Kibana (ELK Demo) | 34.44.185.11 | 5601 | Direct LoadBalancer |
| ArgoCD | 35.188.11.8 | 80, 443 | Direct LoadBalancer |
| Jenkins | 34.29.9.149 | 80 | Direct LoadBalancer |

---

## Access Methods

### Method 1: Direct LoadBalancer Access (Recommended)
Each service has its own external IP - just use the IP directly in your browser.

**Example**:
- Grafana: http://136.111.5.250
- Jenkins: http://34.29.9.149

### Method 2: Through Ingress (Path-based routing)
All services accessible through the main ingress IP with different paths.

**Example**:
- Frontend: http://34.31.22.16
- APIs: http://34.31.22.16/api/auth

### Method 3: With Custom Hostnames (Requires DNS/hosts file)
If you want to use custom domains, add to your local hosts file:

**Windows**: `C:\Windows\System32\drivers\etc\hosts`
```
34.31.22.16    digitalbank.local
34.31.22.16    grafana.digitalbank.local
34.31.22.16    prometheus.digitalbank.local
34.31.22.16    kibana.digitalbank.local
34.31.22.16    argocd.digitalbank.local
```

Then access:
- http://grafana.digitalbank.local
- http://prometheus.digitalbank.local
- etc.

---

## Quick Test Commands

### Test Frontend
```bash
curl http://34.31.22.16
```

### Test APIs
```bash
# Auth API
curl http://34.31.22.16/api/auth/health

# Accounts API
curl http://34.31.22.16/api/accounts/health

# Transactions API
curl http://34.31.22.16/api/transactions/health
```

### Test Monitoring
```bash
# Prometheus
curl http://34.71.18.248:9090/-/healthy

# Grafana
curl http://136.111.5.250/api/health
```

### Test Logs
```bash
# Kibana
curl http://34.173.39.60:5601/api/status
```

### Test DevOps
```bash
# ArgoCD
curl http://35.188.11.8/healthz

# Jenkins
curl http://34.29.9.149/login
```

---

## Security Notes

⚠️ **Important**: These are HTTP endpoints (not HTTPS). For production:

1. **Enable TLS/HTTPS**:
   - Add SSL certificates to ingress
   - Use cert-manager for automatic Let's Encrypt certificates

2. **Add Authentication**:
   - Enable OAuth/OIDC on ArgoCD
   - Configure Jenkins security
   - Protect Grafana/Prometheus with auth proxy

3. **Network Policies**:
   - Restrict access to monitoring tools
   - Use VPN for internal tools
   - Implement IP whitelisting

4. **Change Default Passwords**:
   - ArgoCD admin password
   - Grafana admin password
   - Jenkins admin password

---

## Troubleshooting

### Service Not Accessible?

1. **Check service status**:
```bash
kubectl get svc --all-namespaces | Select-String "LoadBalancer"
```

2. **Check pod status**:
```bash
kubectl get pods -n digitalbank-apps
kubectl get pods -n digitalbank-monitoring
kubectl get pods -n argocd
kubectl get pods -n jenkins
```

3. **Check ingress**:
```bash
kubectl get ingress --all-namespaces
```

4. **View logs**:
```bash
kubectl logs -n digitalbank-apps -l app=auth-api
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### Connection Timeout?

1. **Check firewall rules**:
```bash
gcloud compute firewall-rules list
```

2. **Verify LoadBalancer**:
```bash
kubectl describe svc -n digitalbank-monitoring prometheus-grafana
```

---

## Bookmarks (Save These!)

Quick bookmark list for your browser:

```
📱 Banking App:          http://34.31.22.16
🔐 Auth API:             http://34.31.22.16/api/auth
💰 Accounts API:         http://34.31.22.16/api/accounts
💸 Transactions API:     http://34.31.22.16/api/transactions

📊 Grafana:              http://136.111.5.250
📈 Prometheus:           http://34.71.18.248:9090
🔍 Kibana (Demo):        http://34.63.246.97:5601  ⭐ USE THIS
🔍 Kibana (ELK):         http://34.44.185.11:5601

🚀 ArgoCD:               http://35.188.11.8
🔧 Jenkins:              http://34.29.9.149
```

---

**Last Updated**: January 31, 2026  
**Maintained By**: DevOps Team

For detailed cluster information, see:
- [CLUSTER-INVENTORY.md](CLUSTER-INVENTORY.md)
- [UNDERSTANDING-CLUSTER-PODS.md](UNDERSTANDING-CLUSTER-PODS.md)
