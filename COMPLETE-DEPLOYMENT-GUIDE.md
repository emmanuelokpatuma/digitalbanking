# Digital Banking Platform - Complete Deployment Guide
## Production Deployment on Google Kubernetes Engine

**Project**: Secure FinTech Microservices Platform with DevSecOps Pipeline  
**Author**: Emmanuel Okpatuma  
**Date**: January 2026  
**Infrastructure**: Google Cloud Platform (GKE)  
**Status**: ✅ LIVE & RUNNING

---

## 📊 Current Deployment Status

### Infrastructure Overview
- **GKE Cluster**: digitalbank-gke (us-central1, 3 zones)
- **Nodes**: 3 nodes (e2-standard-2: 2 vCPU, 8GB RAM each)
- **Application Pods**: 4 pods (1 replica per service)
- **Total Pods**: ~90 pods (including monitoring stack)
- **Databases**: 3 Cloud SQL PostgreSQL 15 (ZONAL availability)
- **Monthly Cost**: ~$383/month (optimized for demo/testing)

### Live Service URLs

| Service | Type | URL | Status |
|---------|------|-----|--------|
| **Frontend** | Web App | http://34.31.22.16 | ✅ Running |
| **Auth API** | REST API | http://34.31.22.16/api/auth | ✅ Running |
| **Accounts API** | REST API | http://34.31.22.16/api/accounts | ✅ Running |
| **Transactions API** | REST API | http://34.31.22.16/api/transactions | ✅ Running |
| **ArgoCD** | GitOps | http://35.188.11.8 | ✅ Running |
| **Grafana** | Monitoring | http://136.111.5.250 | ✅ Running |
| **Prometheus** | Metrics | http://34.71.18.248:9090 | ✅ Running |
| **Kibana** | Logs | http://34.44.185.11:5601 | ✅ Running |
| **Jenkins** | CI/CD | http://34.29.9.149 | ✅ Running |

---

## 🏗️ Architecture

### High-Level System Design

```
┌──────────────────────────────────────────────────────────────────┐
│                        Internet Users                             │
└─────────────────────────┬────────────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  Nginx Ingress        │
              │  34.31.22.16          │
              │  (LoadBalancer)       │
              └───────────┬───────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
         ▼                ▼                ▼
    ┌─────────┐    ┌──────────┐    ┌─────────────┐
    │Frontend │    │Auth API  │    │Accounts API │
    │(React)  │    │(Node.js) │    │(Node.js)    │
    └─────────┘    └────┬─────┘    └──────┬──────┘
                        │                  │
                        ▼                  ▼
                 ┌──────────────┐   ┌──────────────┐
                 │ Auth DB      │   │ Accounts DB  │
                 │ PostgreSQL15 │   │ PostgreSQL15 │
                 └──────────────┘   └──────────────┘
                        │
                        ▼
                 ┌──────────────┐
                 │Transactions  │
                 │API (Node.js) │
                 └──────┬───────┘
                        │
                        ▼
                 ┌──────────────┐
                 │Transaction DB│
                 │PostgreSQL 15 │
                 └──────────────┘

Supporting Infrastructure:
├── Jenkins (CI/CD)
├── ArgoCD (GitOps - Auto-sync enabled)
├── Prometheus + Grafana (Monitoring)
├── ELK Stack (Centralized Logging)
└── Kyverno (Policy Enforcement)
```

### Technology Stack

**Application Layer:**
- Frontend: React 18.x + Vite
- Backend: Node.js 18.x + Express.js 4.x
- Databases: PostgreSQL 15.x (Cloud SQL)
- Container Runtime: Docker

**Infrastructure:**
- Cloud Provider: Google Cloud Platform
- Orchestration: Google Kubernetes Engine (GKE)
- IaC: Terraform 1.x
- Networking: VPC-native, Private subnets, Cloud NAT

**CI/CD & DevSecOps:**
- Jenkins 2.x (Automated builds)
- ArgoCD (GitOps deployment)
- Trivy (Container image scanning)
- Checkov (Infrastructure code scanning)
- Kyverno (Runtime policy enforcement)

**Observability:**
- Metrics: Prometheus + Grafana
- Logging: Elasticsearch 7.17 + Kibana 7.17 + Filebeat
- Alerts: Configured in Grafana

---

## 📦 Deployed Components

### 1. Application Services (Namespace: digitalbank-apps)

```yaml
# All services running with 1 replica (optimized for demo)

auth-api:
  replicas: 1
  resources: 512Mi RAM, 500m CPU
  database: digitalbank-auth-db (34.72.18.102)
  
accounts-api:
  replicas: 1
  resources: 512Mi RAM, 500m CPU
  database: digitalbank-accounts-db (34.68.74.165)
  
transactions-api:
  replicas: 1
  resources: 512Mi RAM, 500m CPU
  database: digitalbank-transactions-db (34.30.204.132)
  
digitalbank-frontend:
  replicas: 1
  resources: 256Mi RAM, 250m CPU
  type: React SPA
```

### 2. Database Layer (Cloud SQL)

| Database | Instance | Type | IP | Cost |
|----------|----------|------|-----|------|
| auth-db | digitalbank-auth-db | PostgreSQL 15, ZONAL | 34.72.18.102 (public)<br>10.121.0.2 (private) | ~$65/mo |
| accounts-db | digitalbank-accounts-db | PostgreSQL 15, ZONAL | 34.68.74.165 (public)<br>10.121.0.3 (private) | ~$65/mo |
| transactions-db | digitalbank-transactions-db | PostgreSQL 15, ZONAL | 34.30.204.132 (public)<br>10.121.0.4 (private) | ~$65/mo |

**Database Configuration:**
- Machine Type: db-n1-standard-1 (1 vCPU, 3.75GB RAM)
- Storage: 20GB SSD
- Backups: Automated daily backups (7-day retention)
- Availability: ZONAL (cost-optimized for demo)
- Network: Private IP + Public IP (for DBeaver access)
- SSL: Optional (disabled for testing)

**Database Credentials:**
```bash
# Auth DB
Host: 34.72.18.102 (or 10.121.0.2 from cluster)
Database: authdb
User: authuser
Password: [stored in Kubernetes secret: db-urls]

# Accounts DB
Host: 34.68.74.165 (or 10.121.0.3 from cluster)
Database: accountsdb
User: accountsuser
Password: [stored in Kubernetes secret: db-urls]

# Transactions DB
Host: 34.30.204.132 (or 10.121.0.4 from cluster)
Database: transactionsdb
User: transactionsuser
Password: [stored in Kubernetes secret: db-urls]
```

### 3. Monitoring Stack (Namespace: digitalbank-monitoring)

**Prometheus:**
- URL: http://34.71.18.248:9090
- Storage: Persistent volume (50GB)
- Scrape interval: 30s
- Retention: 15 days

**Grafana:**
- URL: http://136.111.5.250
- Credentials: admin / admin123
- Pre-configured Dashboards:
  - Dashboard 13770: Kubernetes cluster monitoring
  - Dashboard 315: Kubernetes pod/container metrics
  - Dashboard 1860: Node exporter metrics

**AlertManager:**
- Integrated with Prometheus
- Alert rules configured for pod failures, high memory, CPU usage

### 4. Logging Stack (Namespace: elk-demo)

**Elasticsearch:**
- ClusterIP service (internal only)
- Storage: 30GB persistent volume
- Indices: filebeat-*, logstash-*

**Kibana:**
- URL: http://34.44.185.11:5601
- Index pattern: filebeat-*
- Log retention: 7 days

**Filebeat:**
- DaemonSet deployment (runs on every node)
- Collects logs from: /var/log/pods, /var/log/containers
- Ships to: Elasticsearch

### 5. CI/CD Pipeline (Jenkins)

**Jenkins:**
- URL: http://34.29.9.149
- Configured Pipelines:
  - Build & push Docker images
  - Run security scans (Trivy, Checkov)
  - Update Git repository with new tags
  - ArgoCD auto-syncs changes

**Security Scanning:**
- Trivy: Scans container images for vulnerabilities
- Checkov: Scans Terraform/Kubernetes manifests
- Scan results: Fail build on HIGH/CRITICAL findings

### 6. GitOps (ArgoCD)

**ArgoCD:**
- URL: http://35.188.11.8
- Applications:
  1. `digitalbank-production` - Main app deployment
  2. `monitoring-stack` - Prometheus + Grafana
  3. `kyverno-policies` - Policy enforcement

**Auto-sync:** Enabled (30-second polling)
**Sync Policy:** Automated pruning enabled
**Source:** GitHub repository

### 7. Policy Enforcement (Kyverno)

**Installed Policies:**
- Require resource limits on all pods
- Disallow privileged containers
- Require non-root containers
- Validate image sources (allow only trusted registries)
- Enforce label requirements

---

## 🌐 Network Architecture

### VPC Configuration

```
VPC Name: digitalbank-vpc
Region: us-central1
Subnet: digitalbank-subnet

IP Ranges:
├── Nodes:    10.0.0.0/24     (256 IPs - GKE nodes)
├── Pods:     10.1.0.0/16     (65,536 IPs - pod networking)
└── Services: 10.2.0.0/16     (65,536 IPs - ClusterIP services)

Cloud NAT: Enabled (outbound internet for private nodes)
Private Google Access: Enabled (access GCR, Cloud SQL)
```

### Firewall Rules
- Allow SSH (port 22) - admin access
- Allow HTTP/HTTPS (80, 443) - public web traffic
- GKE-managed rules - node-to-pod, pod-to-pod communication

### Load Balancers

| Service | Type | External IP | Monthly Cost |
|---------|------|-------------|--------------|
| Nginx Ingress | LoadBalancer | 34.31.22.16 | $18 |
| ArgoCD | LoadBalancer | 35.188.11.8 | $18 |
| Grafana | LoadBalancer | 136.111.5.250 | $18 |
| Prometheus | LoadBalancer | 34.71.18.248 | $18 |
| Kibana | LoadBalancer | 34.44.185.11 | $18 |
| Jenkins | LoadBalancer | 34.29.9.149 | $18 |

**Total LoadBalancer Cost:** ~$108/month

---

## 🔒 Security Implementation

### 1. Network Security
- ✅ VPC-native cluster (private networking)
- ✅ Private nodes (no public IPs on GKE nodes)
- ✅ Cloud NAT for outbound traffic
- ✅ Firewall rules restricting access

### 2. Database Security
- ✅ Private IP connectivity (10.121.0.x)
- ✅ SSL connections supported
- ✅ Automated backups (daily)
- ✅ Database users with limited permissions
- ✅ Secrets stored in Kubernetes (not in code)

### 3. Container Security
- ✅ Trivy scanning in CI pipeline
- ✅ Kyverno runtime policies
- ✅ Non-root containers enforced
- ✅ Resource limits required
- ✅ Images from trusted registries only

### 4. Application Security
- ✅ JWT-based authentication
- ✅ bcrypt password hashing
- ✅ Environment-based secrets
- ✅ CORS configured
- ✅ Input validation

---

## 🚀 Deployment Workflow

### Current GitOps Flow

```
1. Developer pushes code to GitHub
         ↓
2. Jenkins detects webhook, starts build
         ↓
3. Jenkins builds Docker image
         ↓
4. Trivy scans image for vulnerabilities
         ↓
5. If scan passes, push to Container Registry
         ↓
6. Jenkins updates k8s/production-deployment.yaml
         ↓
7. Jenkins commits & pushes to Git
         ↓
8. ArgoCD detects change (30s polling)
         ↓
9. ArgoCD auto-syncs to GKE cluster
         ↓
10. New pods deployed, old pods terminated
```

**Rollback:** ArgoCD UI → Select previous revision → Sync

---

## 📊 Accessing Services

### 1. Access Frontend Application
```bash
# Open in browser
http://34.31.22.16
```

### 2. Test APIs
```bash
# Using curl

# Register user
curl -X POST http://34.31.22.16/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123",
    "first_name": "Test",
    "last_name": "User"
  }'

# Login
curl -X POST http://34.31.22.16/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123"
  }'

# Get token from login response, then use it
export TOKEN="eyJhbGc..."

# Verify token
curl http://34.31.22.16/api/auth/verify \
  -H "Authorization: Bearer $TOKEN"

# Create account
curl -X POST http://34.31.22.16/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "account_type": "savings",
    "currency": "USD",
    "initial_balance": 1000
  }'
```

### 3. Access Monitoring

**Grafana:**
```bash
# Open in browser
http://136.111.5.250

# Login
Username: admin
Password: admin123

# Import dashboards
Dashboard 13770 - Kubernetes cluster monitoring
Dashboard 315 - Pod/container metrics
Dashboard 1860 - Node exporter metrics
```

**Prometheus:**
```bash
# Open in browser
http://34.71.18.248:9090

# Example queries
- up (all targets status)
- container_memory_usage_bytes (memory usage)
- rate(container_cpu_usage_seconds_total[5m]) (CPU usage)
```

**Kibana:**
```bash
# Open in browser
http://34.44.185.11:5601

# Create index pattern
Management → Index Patterns → Create: filebeat-*

# View logs
Discover → Select filebeat-* → View application logs
```

### 4. Access ArgoCD

```bash
# Open in browser
http://35.188.11.8

# Login credentials
Username: admin
Password: [get from secret]
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### 5. Access Databases (DBeaver)

**Connection Settings:**

**Auth Database:**
- Host: 34.72.18.102
- Port: 5432
- Database: authdb
- Username: authuser
- Password: [from Kubernetes secret]
- SSL: Disabled

**Accounts Database:**
- Host: 34.68.74.165
- Port: 5432
- Database: accountsdb
- Username: accountsuser
- Password: [from Kubernetes secret]
- SSL: Disabled

**Transactions Database:**
- Host: 34.30.204.132
- Port: 5432
- Database: transactionsdb
- Username: transactionsuser
- Password: [from Kubernetes secret]
- SSL: Disabled

**Get passwords:**
```bash
kubectl get secret db-urls -n digitalbank -o yaml
# Decode base64 values
```

---

## 🔧 Common Operations

### Scale Application

```bash
# Scale up/down replicas (via Git for GitOps)
# Edit k8s/production-deployment.yaml
spec:
  replicas: 2  # Change from 1 to 2

# Commit and push
git add k8s/production-deployment.yaml
git commit -m "Scale to 2 replicas"
git push

# ArgoCD will auto-sync within 30 seconds
```

### View Logs

```bash
# Application logs
kubectl logs -n digitalbank-apps deployment/auth-api -f

# All pods in namespace
kubectl logs -n digitalbank-apps --all-containers=true -f

# View in Kibana
# http://34.44.185.11:5601 → Discover → filebeat-*
```

### Check Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods -n digitalbank-apps

# Detailed pod info
kubectl describe pod <pod-name> -n digitalbank-apps
```

### Restart Deployment

```bash
# Restart all pods in a deployment
kubectl rollout restart deployment/auth-api -n digitalbank-apps

# Check rollout status
kubectl rollout status deployment/auth-api -n digitalbank-apps
```

### Database Operations

```bash
# Connect via psql
PGPASSWORD='password' psql -h 34.72.18.102 -U authuser -d authdb

# List tables
\dt

# View data
SELECT * FROM users;

# Or use DBeaver GUI (see section above)
```

---

## 💰 Cost Breakdown

### Monthly Infrastructure Costs

| Component | Specification | Monthly Cost |
|-----------|--------------|--------------|
| **GKE Cluster** | 3 nodes (e2-standard-2) | ~$75 |
| **Cloud SQL Auth DB** | db-n1-standard-1, ZONAL | ~$65 |
| **Cloud SQL Accounts DB** | db-n1-standard-1, ZONAL | ~$65 |
| **Cloud SQL Transactions DB** | db-n1-standard-1, ZONAL | ~$65 |
| **Load Balancers** | 6 LoadBalancers @ $18 each | ~$108 |
| **Storage** | Persistent volumes, backups | ~$5 |
| **Total** | | **~$383/month** |

**Cost Optimizations Applied:**
- ✅ Reduced nodes from 9 to 3 (saved $145/month)
- ✅ Changed databases from REGIONAL to ZONAL (saved $400/month)
- ✅ Scaled replicas from 2 to 1 per service (saved compute resources)
- ❌ LoadBalancers still expensive - could consolidate via Ingress (potential save $90/month)

---

## 🎯 Project Achievements

### ✅ Implemented Features

**Infrastructure:**
- [x] Multi-zone GKE cluster deployment
- [x] VPC-native networking with private nodes
- [x] Cloud SQL databases with automated backups
- [x] Infrastructure as Code with Terraform
- [x] High availability configuration (can scale back up)

**Microservices:**
- [x] 3 independent Node.js microservices
- [x] React frontend application
- [x] JWT-based authentication
- [x] RESTful API design
- [x] Database per service pattern

**DevSecOps:**
- [x] Jenkins CI/CD pipeline
- [x] Automated container image scanning (Trivy)
- [x] IaC security scanning (Checkov)
- [x] Runtime policy enforcement (Kyverno)
- [x] GitOps deployment (ArgoCD)

**Observability:**
- [x] Prometheus metrics collection
- [x] Grafana dashboards
- [x] Centralized logging (ELK stack)
- [x] Log aggregation from all pods

**Security:**
- [x] Private GKE nodes
- [x] Database private IPs
- [x] Network policies
- [x] Secrets management
- [x] Container security policies

---

## 🔗 Important Links

| Resource | URL | Purpose |
|----------|-----|---------|
| Frontend App | http://34.31.22.16 | User interface |
| API Endpoints | http://34.31.22.16/api/* | Backend services |
| ArgoCD | http://35.188.11.8 | GitOps management |
| Grafana | http://136.111.5.250 | Monitoring dashboards |
| Prometheus | http://34.71.18.248:9090 | Metrics & alerts |
| Kibana | http://34.44.185.11:5601 | Log analysis |
| Jenkins | http://34.29.9.149 | CI/CD pipeline |

---

## 📝 Notes

**Current Configuration:**
- Optimized for demo/testing with minimal cost
- All services fully functional
- Can scale up anytime for production load

**For Production Use:**
- Increase replicas to 2-3 per service
- Enable database REGIONAL HA
- Scale nodes to 6-9 for high availability
- Add monitoring alerts
- Configure SSL/TLS certificates
- Implement rate limiting
- Add WAF (Web Application Firewall)

**Last Updated:** January 29, 2026
