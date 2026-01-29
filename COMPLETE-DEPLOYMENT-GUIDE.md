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

## � Understanding the Architecture - For Beginners

### Why This Design? The Big Picture

**Question: Why did we build it this way?**

Think of this platform like a restaurant:
- **Frontend (React)** = The menu customers see
- **APIs (Node.js)** = The kitchen where orders are processed
- **Databases (PostgreSQL)** = The refrigerators storing ingredients
- **Kubernetes (GKE)** = The restaurant building with multiple rooms
- **Load Balancer (Nginx)** = The host who seats customers at the right table
- **Monitoring (Grafana)** = The manager watching everything runs smoothly

### Key Architectural Decisions Explained

#### 1️⃣ **Why Microservices Instead of One Big Application?**

**What we built:**
- 3 separate services: Auth, Accounts, Transactions
- Each service has its own codebase and database

**Why this choice:**
- ✅ **Independence**: Auth team can deploy without affecting Accounts team
- ✅ **Scalability**: If transactions are slow, scale only that service (not everything)
- ✅ **Fault isolation**: If Accounts crashes, Auth still works for login
- ✅ **Technology flexibility**: Could use Python for one service, Node.js for another

**Alternative we rejected:**
- ❌ **Monolith** (one giant application): Simpler to build initially but harder to scale and maintain. One bug could crash everything.

**Real-world example:**
```
Before (Monolith): 
- 1 million users → Need 10 servers for entire app
- Payment processing slow → Have to scale everything (expensive!)

After (Microservices):
- 1 million users → Auth needs 2 servers, Accounts needs 3, Transactions needs 5
- Payment slow → Scale only Transactions service (cheaper!)
```

#### 2️⃣ **Why Separate Databases Per Service?**

**What we built:**
- authdb: Stores only users and passwords
- accountsdb: Stores only bank accounts
- transactionsdb: Stores only payment records

**Why this choice:**
- ✅ **Data isolation**: Accounts service can't accidentally delete users
- ✅ **Independent scaling**: Transactions DB can be larger/faster than Auth DB
- ✅ **Security**: If one DB is breached, others are still safe
- ✅ **Microservice pattern**: Each service owns its data completely

**Alternative we rejected:**
- ❌ **Single shared database**: All services touching same DB creates bottlenecks and tight coupling. Schema changes affect everyone.

**How they connect:**
```
User flow: Register → Create Account → Make Transaction

1. POST /api/auth/register
   → Auth API checks authdb
   → Returns JWT token with user_id
   
2. POST /api/accounts (with token)
   → Accounts API verifies token with Auth API
   → Creates account in accountsdb using user_id
   
3. POST /api/transactions (with token)
   → Transactions API verifies token
   → Checks account_id exists via Accounts API
   → Records transaction in transactionsdb
```

#### 3️⃣ **Why Kubernetes (GKE) Instead of Virtual Machines?**

**What we built:**
- GKE cluster with 3 nodes
- Applications run in containers (Docker)
- Kubernetes manages container lifecycle

**Why this choice:**
- ✅ **Auto-healing**: If a container crashes, Kubernetes restarts it automatically
- ✅ **Easy scaling**: `kubectl scale deployment auth-api --replicas=5` (done!)
- ✅ **Resource efficiency**: Multiple containers per node (better than 1 VM per app)
- ✅ **Portability**: Same containers run on dev laptop, test, and production
- ✅ **Industry standard**: Modern cloud-native approach

**Alternative we rejected:**
- ❌ **VMs**: Each app needs its own VM (expensive, slow to start, wastes resources)
- ❌ **Serverless (Cloud Run)**: Great for simple apps but doesn't give us Kubernetes control/monitoring we need

**Understanding the hierarchy:**
```
Google Cloud Platform (GCP)
  └── GKE Cluster: digitalbank-gke
       ├── Node 1 (Physical VM in us-central1-a)
       │    ├── Pod: auth-api (container running Node.js)
       │    ├── Pod: prometheus-server (container running Prometheus)
       │    └── Pod: filebeat (container collecting logs)
       │
       ├── Node 2 (Physical VM in us-central1-b)
       │    ├── Pod: accounts-api
       │    └── Pod: grafana
       │
       └── Node 3 (Physical VM in us-central1-c)
            ├── Pod: transactions-api
            └── Pod: kibana
```

**Why 3 nodes across 3 zones?**
- Zone a goes down → Nodes in zone b and c still run (high availability)
- Even distribution → No single point of failure
- Cost-optimized: 3 nodes enough for demo (originally had 9 for production HA)

#### 4️⃣ **Why Private Networking with Cloud NAT?**

**What we built:**
- Nodes have NO public IPs (private: 10.0.0.x)
- Pods have private IPs (10.1.0.x)
- Cloud NAT provides internet access

**Why this choice:**
- ✅ **Security**: Hackers can't directly access nodes (no public IP to attack)
- ✅ **DDoS protection**: All traffic routes through Load Balancers with protection
- ✅ **Compliance**: Many regulations require private infrastructure
- ✅ **Cost**: Public IPs cost money, private IPs are free

**How it works:**
```
Scenario 1: User visits website
Internet User → Load Balancer (34.31.22.16) 
            → Ingress Controller (pod in cluster)
            → Frontend Pod (10.1.3.5)
            
Scenario 2: Pod needs to download something
Frontend Pod (10.1.3.5) → Cloud NAT (acts as proxy)
                       → Internet → Downloads npm packages
                       
✅ Inbound: Only through controlled Load Balancer
✅ Outbound: Through Cloud NAT (allows installing packages)
❌ Direct access to pods: BLOCKED
```

**Alternative we rejected:**
- ❌ **Public IPs on nodes**: Easier to set up but HUGE security risk. Every node exposed to internet attacks.

#### 5️⃣ **Why Nginx Ingress Instead of Multiple LoadBalancers?**

**What we chose:**
- 1 LoadBalancer (34.31.22.16) for ALL application traffic
- Routes based on URL path:
  - `/` → Frontend
  - `/api/auth` → Auth API
  - `/api/accounts` → Accounts API
  - `/api/transactions` → Transactions API

**Why this choice:**
- ✅ **Cost savings**: 1 LoadBalancer ($18/mo) vs 4 LoadBalancers ($72/mo)
- ✅ **Single entry point**: Easier SSL certificate management
- ✅ **Centralized routing**: One place to configure all traffic rules
- ✅ **Performance**: Nginx is extremely fast at routing

**How URL routing works:**
```
User Request: http://34.31.22.16/api/auth/login

1. Hits LoadBalancer (34.31.22.16)
2. LoadBalancer forwards to Nginx Ingress Controller (pod)
3. Ingress checks path: /api/auth
4. Ingress routes to auth-api service (10.2.171.160:3001)
5. Service selects healthy auth-api pod (10.1.3.14)
6. Pod processes login request
7. Response travels back same path

All in milliseconds!
```

**Why monitoring still has separate LoadBalancers:**
- Grafana, Prometheus, Kibana have their own IPs for easy access
- Not user-facing, so less concern about cost
- Want independent access (don't want monitoring to fail if main Ingress fails)

#### 6️⃣ **Why GitOps with ArgoCD?**

**What we built:**
- Git repository as single source of truth
- ArgoCD watches Git, automatically deploys changes
- No manual `kubectl apply` commands

**Why this choice:**
- ✅ **Audit trail**: Every change in Git history (who changed what, when, why)
- ✅ **Easy rollback**: `git revert` to undo bad deployment
- ✅ **Declarative**: Describe WHAT you want, not HOW to do it
- ✅ **Consistency**: Dev, staging, prod all deploy the same way
- ✅ **Team collaboration**: Review changes via Pull Requests before deployment

**The workflow:**
```
Developer → Edits k8s/production-deployment.yaml
         → Commits to Git
         → Pushes to GitHub
         
ArgoCD (running in cluster):
         → Polls Git every 30 seconds
         → Sees deployment changed replicas: 1 → 2
         → Compares Git vs actual cluster state
         → Detects difference
         → Automatically applies change
         → Pods scale up to 2 replicas
         
Result: Zero manual intervention! Git = reality in cluster
```

**Alternative we rejected:**
- ❌ **Manual kubectl**: Error-prone, no history, "works on my machine" problems
- ❌ **CI/CD only (Jenkins)**: Jenkins builds images but shouldn't directly deploy (separation of concerns)

#### 7️⃣ **Why Jenkins for CI/CD?**

**What we built:**
- Jenkins pipelines triggered by Git pushes
- Automated: Build → Test → Security Scan → Push Image → Update Git

**Why this choice:**
- ✅ **Industry standard**: Most companies use Jenkins or similar
- ✅ **Flexibility**: Can customize any step in pipeline
- ✅ **Plugins**: Trivy for scanning, Checkov for IaC validation
- ✅ **Security gates**: Block deployment if vulnerabilities found

**Pipeline explained step-by-step:**
```
1. Developer pushes code to GitHub
   
2. GitHub webhook triggers Jenkins

3. Jenkins Pipeline Runs:
   
   Stage 1: Checkout Code
   ├── Clones Git repository
   └── Checks out the new commit
   
   Stage 2: Build Docker Image
   ├── Runs: docker build -t auth-api:v1.2.3
   └── Creates container image with app code
   
   Stage 3: Security Scan (Trivy)
   ├── Scans image for vulnerabilities
   ├── Checks for outdated packages
   └── FAILS build if HIGH/CRITICAL issues
   
   Stage 4: Push to Registry
   ├── docker push gcr.io/project/auth-api:v1.2.3
   └── Image now available for deployment
   
   Stage 5: Update Kubernetes Manifest
   ├── Edits k8s/production-deployment.yaml
   ├── Changes image: auth-api:v1.2.2 → auth-api:v1.2.3
   ├── Commits to Git
   └── Pushes to GitHub
   
4. ArgoCD detects Git change → Deploys new version
```

**Why separate Jenkins and ArgoCD?**
- Jenkins = Build & Test (CI - Continuous Integration)
- ArgoCD = Deploy (CD - Continuous Deployment)
- Separation of concerns: Jenkins shouldn't directly touch production cluster

#### 8️⃣ **Why Prometheus + Grafana for Monitoring?**

**What we built:**
- Prometheus: Collects metrics every 30 seconds
- Grafana: Visualizes metrics in dashboards
- AlertManager: Sends alerts when issues detected

**Why this choice:**
- ✅ **Industry standard**: Used by Netflix, Uber, GitLab
- ✅ **Pull-based**: Prometheus scrapes metrics (services don't push)
- ✅ **Time-series DB**: Perfect for monitoring metrics over time
- ✅ **Powerful queries**: PromQL language for complex analysis
- ✅ **Free & open-source**: No licensing costs

**What gets monitored:**
```
Node Level:
- CPU usage per node
- Memory usage per node
- Disk I/O
- Network traffic

Pod Level:
- Number of running pods
- Pod restarts (sign of crashes)
- Container CPU/memory per pod
- HTTP request rates

Application Level:
- API response times
- Error rates (5xx responses)
- Database connection pool size
- JWT token validations/sec
```

**How it works:**
```
1. Prometheus scrapes metrics from:
   ├── Kubernetes API (cluster metrics)
   ├── Node Exporter (node metrics)
   ├── cAdvisor (container metrics)
   └── Application endpoints (/metrics)
   
2. Stores in time-series database

3. Grafana queries Prometheus:
   - Displays in pretty graphs
   - Shows trends over time
   - Alerts if thresholds exceeded
   
Example Query:
"Show me auth-api memory usage last 24 hours"
→ Grafana sends: container_memory_usage_bytes{pod="auth-api"}
→ Prometheus returns: data points
→ Grafana draws: graph showing memory trend
```

#### 9️⃣ **Why ELK Stack for Logging?**

**What we built:**
- Elasticsearch: Stores logs
- Kibana: Search and visualize logs
- Filebeat: Collects logs from nodes

**Why this choice:**
- ✅ **Centralized logging**: All pod logs in one place
- ✅ **Powerful search**: Find specific errors across all services
- ✅ **Troubleshooting**: See what happened before crash
- ✅ **Compliance**: Audit trail for financial transactions

**Problem it solves:**
```
Without ELK:
- 90 pods running across 3 nodes
- Bug in production: "Transaction failed for user X"
- How to find logs?
  1. SSH to node 1 → check logs → not here
  2. SSH to node 2 → check logs → not here
  3. SSH to node 3 → found it! But pod restarted, logs gone 😢
  
With ELK:
- Open Kibana in browser
- Search: "Transaction failed for user X"
- Instantly see: logs from all pods, all times
- Click log → see full context (before/after)
- Even if pod deleted, logs still in Elasticsearch
```

**Log flow:**
```
Application Pod (auth-api)
  ↓ console.log("User logged in: user123")
  
Node's /var/log/pods/auth-api.log
  ↓
  
Filebeat (DaemonSet on each node)
  ↓ Reads log files every few seconds
  
Elasticsearch
  ↓ Indexes and stores
  
Kibana
  ↓ Search interface
  
You: Search for "user123" → Find log in 1 second!
```

#### 🔟 **Why Kyverno for Policy Enforcement?**

**What we built:**
- Policies that run on every pod created
- Blocks pods that don't meet security standards

**Why this choice:**
- ✅ **Prevents mistakes**: Can't accidentally deploy insecure pod
- ✅ **Compliance**: Enforce company/regulatory standards
- ✅ **Automated**: No manual reviews needed
- ✅ **Kubernetes-native**: Works seamlessly with Kubernetes

**Example policies:**
```
Policy 1: Require Resource Limits
❌ Blocked: Pod without memory/CPU limits
   → Could crash node by using all resources
✅ Allowed: Pod with limits set
   → Can only use max 512Mi RAM, 500m CPU

Policy 2: No Privileged Containers
❌ Blocked: Pod running as root
   → Could break out of container, access host
✅ Allowed: Pod running as non-root user (UID 1000)
   → Contained, can't escape

Policy 3: Trusted Image Sources
❌ Blocked: Pod using image from unknown-registry.com
   → Could contain malware
✅ Allowed: Pod using gcr.io/our-project/auth-api
   → Our verified image
```

**How it works:**
```
Developer: kubectl apply -f bad-pod.yaml

Kubernetes receives request
  ↓
Kyverno intercepts (admission controller)
  ↓
Checks pod against all policies:
  ├── Resource limits? ❌ MISSING
  ├── Non-root user? ✅ PASS
  └── Trusted image? ✅ PASS
  
Result: REQUEST DENIED
Error: "Pod must specify resource limits"

Developer fixes bad-pod.yaml → tries again → ✅ ALLOWED
```

---

## �🏗️ Architecture

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

## 🔗 How Everything Connects: The Complete Flow

### Understanding Nodes, Pods, and Services

**Think of it like an apartment building:**
- **Node** = The building (physical infrastructure)
- **Pod** = An apartment (runs your application)
- **Service** = The building's address/doorbell (how to find apartments)
- **Ingress** = The lobby directory (routes visitors to right apartment)

### The Physical to Logical Hierarchy

```
1. PHYSICAL LAYER (Google's Hardware)
   └── us-central1 region
       ├── Zone A data center
       │   └── Physical server running VM
       │       └── Node 1: gke-digitalbank-gke-node-abc123
       │
       ├── Zone B data center
       │   └── Physical server running VM
       │       └── Node 2: gke-digitalbank-gke-node-def456
       │
       └── Zone C data center
           └── Physical server running VM
               └── Node 3: gke-digitalbank-gke-node-ghi789

2. KUBERNETES LAYER (Software Abstraction)
   └── Cluster: digitalbank-gke
       └── Nodes (VMs that run containers)
           └── Pods (containers running your code)
               └── Containers (Docker images)

3. APPLICATION LAYER (Your Code)
   └── Microservices
       ├── auth-api (authenticates users)
       ├── accounts-api (manages accounts)
       └── transactions-api (processes payments)
```

### Example: What Happens When You Access the Website

**Step-by-step flow:**

```
1. USER ACTION
   User types: http://34.31.22.16
   Browser sends HTTP request
   
2. GOOGLE CLOUD LOAD BALANCER
   IP 34.31.22.16 (public internet)
   ├── Receives request from internet
   ├── DDoS protection kicks in
   ├── Health check: Is Ingress pod healthy? ✅
   └── Forwards to: Nginx Ingress Controller pod
   
3. NGINX INGRESS CONTROLLER (Pod in Cluster)
   IP: 10.1.5.23 (pod IP, internal only)
   ├── Checks URL path: "/"
   ├── Matches rule: "/" → digitalbank-frontend service
   └── Forwards to: frontend service (10.2.194.118)
   
4. KUBERNETES SERVICE (Virtual IP)
   frontend service (ClusterIP: 10.2.194.118)
   ├── Type: ClusterIP (internal load balancer)
   ├── Selector: app=digitalbank-frontend
   ├── Finds pods with that label
   ├── Picks healthy pod (round-robin)
   └── Forwards to: frontend pod (10.1.7.45:80)
   
5. FRONTEND POD (Container)
   Pod: digitalbank-frontend-abc123
   ├── IP: 10.1.7.45 (assigned by Kubernetes)
   ├── Running on: Node 2 (10.0.0.15)
   ├── Container: nginx serving React build
   ├── Reads files from container filesystem
   └── Returns: HTML, CSS, JavaScript files
   
6. RESPONSE TRAVELS BACK
   Frontend Pod → Service → Ingress → Load Balancer → User
   User's browser displays the website!
```

**Now user logs in:**

```
1. USER SUBMITS LOGIN FORM
   POST http://34.31.22.16/api/auth/login
   Body: { "email": "user@example.com", "password": "pass123" }
   
2. LOAD BALANCER → INGRESS
   Same as before (34.31.22.16 → Nginx Ingress)
   
3. INGRESS CHECKS PATH
   Path: /api/auth/login
   ├── Matches rule: /api/auth(/|$)(.*)
   ├── Rewrite rule: Remove /api/auth prefix
   └── Forward to: auth-api service
   
4. AUTH-API SERVICE
   Service: auth-api (ClusterIP: 10.2.171.160:3001)
   └── Selects: auth-api pod (10.1.3.14)
   
5. AUTH-API POD PROCESSES REQUEST
   Pod: auth-api-5dfdf8556b-2czrq
   ├── Running: Node.js + Express application
   ├── Needs database connection
   ├── Environment variable: DB_HOST=10.121.0.2 (Cloud SQL private IP)
   └── Connects to: PostgreSQL database
   
6. DATABASE CONNECTION (CLOUD SQL)
   ├── Pod IP: 10.1.3.14 (in VPC)
   ├── Database IP: 10.121.0.2 (private, in same VPC)
   ├── Connection: Through VPC peering (no internet!)
   ├── Query: SELECT * FROM users WHERE email = 'user@example.com'
   └── Returns: User record with hashed password
   
7. AUTH-API POD CONTINUES
   ├── Compares password hash: bcrypt.compare(...)
   ├── Password matches! ✅
   ├── Generates JWT token: jwt.sign({ userId: 123 }, secret)
   └── Returns: { token: "eyJhbGc...", userId: 123 }
   
8. RESPONSE TRAVELS BACK
   Auth Pod → Service → Ingress → LB → User
   Frontend stores token in localStorage
```

**Now user creates bank account:**

```
1. USER SUBMITS CREATE ACCOUNT
   POST http://34.31.22.16/api/accounts
   Headers: { "Authorization": "Bearer eyJhbGc..." }
   Body: { "account_type": "savings", "currency": "USD" }
   
2. INGRESS ROUTES TO ACCOUNTS-API
   Path: /api/accounts
   → accounts-api service (10.2.xxx.xxx)
   → accounts-api pod (10.1.8.22)
   
3. ACCOUNTS-API VERIFIES TOKEN
   Pod: accounts-api-7c8d9f6g5h-xyz789
   ├── Extracts token from Authorization header
   ├── Needs to verify with Auth service (microservice communication!)
   ├── Makes internal request: http://auth-api:3001/api/auth/verify
   │   └── Kubernetes DNS resolves "auth-api" → 10.2.171.160
   │   └── Routed to auth-api pod
   │   └── Auth API verifies token, returns userId
   └── Token valid! ✅
   
4. ACCOUNTS-API CREATES ACCOUNT
   ├── Now knows userId from token
   ├── Connects to accountsdb (10.121.0.3)
   ├── INSERT INTO accounts (user_id, type, currency, balance)
   │   VALUES (123, 'savings', 'USD', 0.00)
   ├── Database returns: account_id = 456
   └── Returns: { account_id: 456, balance: 0.00 }
```

### How Pods Talk to Each Other (Service Discovery)

**Problem:** Pod IPs change when pods restart!
- auth-api pod crashes → Kubernetes starts new pod → NEW IP!
- How does accounts-api find the new auth-api pod?

**Solution:** Kubernetes Services (stable virtual IPs)

```
Scenario: Accounts-API needs to verify token with Auth-API

Wrong Way (brittle):
accounts-api → http://10.1.3.14:3001/verify
                     ↑
                     Pod IP changes when pod restarts!

Right Way (using Services):
accounts-api → http://auth-api:3001/verify
                     ↑
                     Service name (DNS)
                     
Kubernetes DNS resolves:
auth-api → 10.2.171.160 (Service ClusterIP - stable!)
           
Service selects healthy pod:
10.2.171.160 → 10.1.3.14 (current pod IP)

If pod restarts with new IP 10.1.9.99:
Service automatically updates → now forwards to 10.1.9.99
accounts-api code unchanged! Still uses "auth-api:3001"
```

### How Pods Connect to Databases (VPC Peering)

**The networking challenge:**
- Pods in GKE: 10.1.0.0/16 (managed by Google Kubernetes)
- Cloud SQL: 10.121.0.0/16 (managed by Google Cloud SQL)
- Different networks! How do they talk?

**Solution:** VPC Peering via Service Networking

```
Setup (done by Terraform):
1. Reserve IP range: 10.121.0.0/16 for Cloud SQL
2. Create service connection: VPC ↔ servicenetworking.googleapis.com
3. Cloud SQL instances get IPs: 10.121.0.2, 10.121.0.3, 10.121.0.4

Result: Both networks connected!
digitalbank-vpc (10.0.0.0/8 supernet)
├── GKE Subnet: 10.0.0.0/24 (nodes)
├── GKE Pods: 10.1.0.0/16
├── GKE Services: 10.2.0.0/16
└── Cloud SQL: 10.121.0.0/16 (peered)

Pod can reach database:
auth-api pod (10.1.3.14) → ping 10.121.0.2 → SUCCESS!
Traffic stays in Google's private network (fast + secure)
```

### Why Nodes Are Private (No Public IPs)

**What we configured:**
```hcl
private_cluster_config {
  enable_private_nodes = true   # Nodes get only private IPs
}
```

**IP assignments:**
```
Node 1:
├── Public IP: NONE ❌
└── Private IP: 10.0.0.12 ✅
    └── Can be reached by: Other nodes in VPC
    └── Cannot be reached by: Internet

But wait! How does node install packages from internet?
```

**Enter Cloud NAT:**
```
Node needs to: apt-get install package

Without NAT:
Node (10.0.0.12) → tries to reach ubuntu.com
                → No public IP, request fails ❌
                
With Cloud NAT:
Node (10.0.0.12) → Cloud NAT (acts as proxy)
                 → Cloud NAT has public IP
                 → NAT requests package from ubuntu.com
                 → NAT returns package to node ✅
                 
Outbound: Works (through NAT)
Inbound: Blocked (no public IP to attack)
```

### The Complete Request Flow Diagram

```
EXTERNAL REQUEST FLOW:
====================
Internet User (anywhere in world)
    ↓
Google Cloud Load Balancer (34.31.22.16)
    ├── DDoS protection
    ├── SSL termination (if HTTPS)
    └── Health checks
    ↓
Nginx Ingress Controller Pod (10.1.5.23)
    ├── Running on: Node 1 or 2 or 3 (Kubernetes schedules it)
    ├── URL pattern matching
    └── Request routing
    ↓
Kubernetes Service (ClusterIP: 10.2.x.x)
    ├── Virtual IP (doesn't exist on any node)
    ├── iptables rules on nodes
    └── Load balancing to pods
    ↓
Application Pod (10.1.x.x)
    ├── Running on: Specific node
    ├── Container runtime: Docker
    └── App code: Node.js/React
    ↓
Database (10.121.0.x)
    ├── Cloud SQL (managed PostgreSQL)
    ├── VPC peering connection
    └── Private IP only (secure)

INTERNAL REQUEST FLOW:
=====================
accounts-api pod → auth-api pod
    ↓
Use Kubernetes Service DNS:
http://auth-api:3001/verify
    ↓
Kubernetes DNS resolves:
auth-api → 10.2.171.160
    ↓
Service forwards to pod:
10.2.171.160 → 10.1.3.14
    ↓
Pod processes request
```

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
