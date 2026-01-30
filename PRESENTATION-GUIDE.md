# 🎤 Digital Banking Platform - 1-Hour Presentation Guide

**Project:** Secure FinTech Microservices Platform  
**Author:** Emmanuel Okpatuma  
**Presentation Duration:** 60 minutes  
**Last Updated:** January 30, 2026

---

## 📋 Presentation Agenda (60 minutes)

| Time | Section | Duration |
|------|---------|----------|
| 0:00-0:05 | Introduction & Project Overview | 5 min |
| 0:05-0:20 | Infrastructure as Code (Terraform) | 15 min |
| 0:20-0:30 | GKE Cluster & Nodes Architecture | 10 min |
| 0:30-0:40 | Microservices Architecture | 10 min |
| 0:40-0:50 | CI/CD Pipeline & DevOps Tools | 10 min |
| 0:50-0:55 | Monitoring & Logging Stack | 5 min |
| 0:55-1:00 | Live Demo & Q&A | 5 min |

---

## 🎬 SECTION 1: Introduction & Project Overview (5 minutes)

### Slide 1: Title Slide

**What to say:**
> "Good morning/afternoon everyone. Today I'm presenting a production-grade Digital Banking Platform that I built from scratch on Google Cloud Platform. This is a complete fintech microservices architecture with full DevOps automation, monitoring, and security."

**Key Points:**
- Project name: Digital Banking Platform
- Built entirely from scratch (no templates)
- Production-ready infrastructure
- Real banking features: accounts, transfers, transactions

### Slide 2: The Problem Statement

**What to say:**
> "Traditional banking applications face several challenges: monolithic architecture that's hard to scale, manual infrastructure setup prone to errors, lack of observability, and deployment bottlenecks. I set out to solve these problems using modern cloud-native technologies."

**Show on screen:**
```
Traditional Banking Apps:
❌ Monolithic architecture
❌ Manual infrastructure (prone to errors)
❌ Difficult to scale
❌ No observability
❌ Slow deployments

My Solution:
✅ Microservices architecture
✅ Infrastructure as Code (Terraform)
✅ Kubernetes for orchestration
✅ Full observability (Prometheus, Grafana, ELK)
✅ Automated CI/CD (Jenkins, ArgoCD)
```

### Slide 3: Technology Stack

**What to say:**
> "Here's the complete technology stack I used. For infrastructure, I chose Terraform for its declarative approach and Google Kubernetes Engine for container orchestration. The applications are built with Node.js and React, databases on Cloud SQL, and a full DevOps stack including Jenkins for CI/CD, ArgoCD for GitOps, and comprehensive monitoring."

**Show on screen:**
```
☁️ CLOUD INFRASTRUCTURE
├─ Google Cloud Platform (GCP)
├─ Terraform (Infrastructure as Code)
├─ Google Kubernetes Engine (GKE)
└─ Cloud SQL (PostgreSQL 15)

🔧 APPLICATION STACK
├─ Backend: Node.js + Express
├─ Frontend: React 18 + Vite
├─ Databases: PostgreSQL 15
└─ Container Runtime: Docker

⚙️ DEVOPS TOOLS
├─ CI/CD: Jenkins
├─ GitOps: ArgoCD
├─ Monitoring: Prometheus + Grafana
├─ Logging: Elasticsearch + Logstash + Kibana
├─ Container Registry: Google Container Registry
└─ Version Control: Git + GitHub
```

### Slide 4: Architecture Overview Diagram

**What to say:**
> "This is the high-level architecture. We have 3 availability zones for high availability, 9 Kubernetes nodes running 180+ pods, 4 microservices, 3 separate databases, and a complete monitoring stack. Everything is managed through Infrastructure as Code and GitOps."

**Show diagram:**
```
                    ┌─────────────────────────────────────┐
                    │   Google Cloud Platform (GCP)       │
                    │   Project: charged-thought-485008   │
                    └─────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
   Zone A (3 nodes)          Zone B (3 nodes)          Zone C (3 nodes)
        │                           │                           │
    ┌───┴───┐                   ┌───┴───┐                   ┌───┴───┐
    │  60   │                   │  60   │                   │  64   │
    │ pods  │                   │ pods  │                   │ pods  │
    └───────┘                   └───────┘                   └───────┘
        │
    ┌───┴─────────────────────────────────────────────┐
    │          Application Pods (4 services)          │
    ├─────────────────────────────────────────────────┤
    │ • Frontend (React)                              │
    │ • Auth API (Node.js)                           │
    │ • Accounts API (Node.js)                       │
    │ • Transactions API (Node.js)                   │
    └─────────────────────────────────────────────────┘
                        │
    ┌───────────────────┴───────────────────┐
    │     Cloud SQL Databases (3)           │
    ├───────────────────────────────────────┤
    │ • Auth DB (PostgreSQL 15)            │
    │ • Accounts DB (PostgreSQL 15)        │
    │ • Transactions DB (PostgreSQL 15)    │
    └───────────────────────────────────────┘
```

**Open terminal and show:**
```bash
# Show you're connected to the real cluster
gcloud config get-value project
kubectl get nodes
```

---

## 🏗️ SECTION 2: Infrastructure as Code with Terraform (15 minutes)

### Slide 5: Why Terraform?

**What to say:**
> "I chose Terraform for infrastructure management because it solves a critical problem. Let me show you the difference between manual infrastructure and Infrastructure as Code."

**Show comparison:**
```
BEFORE TERRAFORM (Manual Setup):
Day 1:  Login to GCP Console → Click through wizards
        Create VPC → Create Subnets → Create Firewall rules
        Create GKE cluster (20-minute wizard)
        Oops! Typo in cluster name, delete and start over
        Time: 2 hours, prone to human error

Day 30: Need to create test environment
        What were the settings?
        Check screenshots from Day 1
        Different person, different clicks
        Result: Test ≠ Production 😢

Day 60: Disaster! Subnet accidentally deleted
        What was the IP range?
        2 hours recreating from memory

WITH TERRAFORM (Infrastructure as Code):
Day 1:  Write code once
        terraform apply
        Time: 5 minutes, all resources created

Day 30: Need test environment
        terraform apply -var="env=test"
        Exact same setup! ✅

Day 60: Disaster recovery
        git checkout network.tf
        terraform apply
        Recreated perfectly in minutes! ✅
```

### Slide 6: Infrastructure Components

**What to say:**
> "My infrastructure consists of 35 Terraform-managed resources. Let me break this down into logical layers."

**Show on screen:**
```
TERRAFORM RESOURCES: 35 Total

1. NETWORK LAYER (7 resources)
   ├─ VPC Network (custom, isolated)
   ├─ Subnet with 3 IP ranges
   │  ├─ Primary: 10.0.0.0/24 (nodes)
   │  ├─ Secondary: 10.1.0.0/16 (pods - 65k IPs)
   │  └─ Secondary: 10.2.0.0/16 (services - 65k IPs)
   ├─ Cloud Router
   ├─ Cloud NAT (secure internet access)
   ├─ Firewall rules (SSH, HTTP/HTTPS)
   └─ Private IP range for databases

2. COMPUTE LAYER (10 resources)
   ├─ GKE Cluster (multi-zone)
   ├─ 3 Node Pools (one per zone)
   ├─ Autoscaling config (3-10 nodes per zone)
   └─ Node configuration (e2-standard-2)

3. DATABASE LAYER (9 resources)
   ├─ 3 Cloud SQL instances (PostgreSQL 15)
   ├─ 3 Databases (authdb, accountsdb, transactionsdb)
   └─ 3 Database users with generated passwords

4. SERVICE NETWORKING (2 resources)
   ├─ Private VPC connection
   └─ IP address reservation

5. STATE MANAGEMENT (1 resource)
   └─ GCS bucket for remote state

6. DATA SOURCES (6 resources)
   └─ GCP project info, zones, etc.
```

### LIVE DEMO 1: Show Terraform Code

**What to do:**
```bash
# Navigate to terraform directory
cd terraform/

# Show file structure
ls -la

# Show main.tf
code main.tf
```

**What to say while showing code:**
> "Here's my main.tf file. Notice the backend configuration using Google Cloud Storage - this allows my team to collaborate on infrastructure changes. The state is locked, preventing concurrent modifications."

**Scroll to show:**
```hcl
backend "gcs" {
  bucket = "charged-thought-485008-q7-tfstate"
  prefix = "digitalbank/terraform/state"
}
```

**Then show network.tf:**
```bash
code network.tf
```

**What to say:**
> "This is where I define the network infrastructure. Notice the subnet has three IP ranges - one for nodes, and two secondary ranges for Kubernetes pods and services. This is crucial for GKE to efficiently allocate IPs."

**Highlight this section:**
```hcl
resource "google_compute_subnetwork" "subnet" {
  name          = "digitalbank-subnet"
  ip_cidr_range = "10.0.0.0/24"  # Nodes
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"  # 65,536 pod IPs
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"  # 65,536 service IPs
  }
}
```

### LIVE DEMO 2: Terraform Commands

**Run these commands:**
```bash
# Show current state
terraform state list

# Output:
# Shows all 35 resources

# Show specific resource
terraform state show google_container_cluster.primary

# Show plan (no changes since infrastructure is stable)
terraform plan

# Output: "No changes. Your infrastructure matches the configuration."
```

**What to say:**
> "As you can see, terraform plan shows no changes because my infrastructure is stable and matches the code. If I were to make any changes to the .tf files, Terraform would show me exactly what would change before I apply it."

### Slide 7: Terraform Workflow

**What to say:**
> "Here's my typical workflow when making infrastructure changes. Everything goes through version control and code review."

**Show workflow:**
```
1. MAKE CHANGES
   ├─ Edit .tf files locally
   └─ git commit -m "Add Redis cache"

2. REVIEW
   ├─ terraform plan (see what will change)
   ├─ Code review by team
   └─ Approve pull request

3. APPLY
   ├─ terraform apply
   ├─ Terraform creates/modifies resources
   └─ State updated in GCS bucket

4. VERIFY
   ├─ Check GCP Console
   └─ Test the changes
```

---

## 🎛️ SECTION 3: GKE Cluster & Nodes Architecture (10 minutes)

### Slide 8: Kubernetes Cluster Overview

**What to say:**
> "Let me show you the Kubernetes cluster architecture. This is a production-grade, multi-zone GKE cluster running 9 nodes across 3 availability zones."

**Show on screen:**
```
CLUSTER SPECIFICATIONS:
├─ Name: digitalbank-gke
├─ Type: Regional (multi-zone)
├─ Region: us-central1
├─ Zones: us-central1-a, us-central1-b, us-central1-c
├─ Kubernetes Version: v1.33.5-gke.2100000
└─ Control Plane: Managed by Google (HA across zones)

NODE SPECIFICATIONS:
├─ Total Nodes: 9 (3 per zone)
├─ Machine Type: e2-standard-2
├─ vCPUs: 2 per node (18 total)
├─ Memory: 8GB per node (72GB total)
├─ Disk: 50GB SSD per node
└─ Total Pods: 180+ across all nodes

AUTOSCALING:
├─ Minimum: 3 nodes per zone (9 total)
├─ Maximum: 10 nodes per zone (30 total)
└─ Scales based on CPU/Memory utilization
```

### LIVE DEMO 3: Show Real Cluster

**Run commands:**
```bash
# Show cluster info
gcloud container clusters describe digitalbank-gke --region us-central1 \
  --format="table(name,location,currentMasterVersion,currentNodeCount,status)"

# Show all nodes
kubectl get nodes -o wide

# Show node distribution by zone
kubectl get nodes --label-columns=topology.kubernetes.io/zone

# Show resource usage
kubectl top nodes
```

**What to say:**
> "Here are the 9 nodes running right now. Notice they're distributed across three zones - this means if an entire Google data center goes down, my application keeps running on the other zones. Google guarantees 99.95% uptime for multi-zone clusters."

### Slide 9: Node & Pod Distribution

**What to say:**
> "Let me show you how the 180+ pods are distributed across these nodes. This is important for understanding resource utilization and high availability."

**Show breakdown:**
```
ZONE A (us-central1-a) - 3 nodes, 59 pods
├─ Node 1: gke-digitalbank-gke-n-17ab08f8-698s
│  ├─ Pods: 23
│  └─ Key workloads: accounts-api, frontend, transactions-api
│
├─ Node 2: gke-digitalbank-gke-n-17ab08f8-cz5j (newest node)
│  ├─ Pods: 15
│  └─ Key workloads: elasticsearch-master-1, jenkins
│
└─ Node 3: gke-digitalbank-gke-n-17ab08f8-fjkp
   ├─ Pods: 21
   └─ Key workloads: auth-api, elasticsearch-master-0

ZONE B (us-central1-b) - 3 nodes, 60 pods
├─ Node 4: Highest load (25 pods) - Prometheus, Grafana
├─ Node 5: 18 pods
└─ Node 6: 17 pods

ZONE C (us-central1-c) - 3 nodes, 64 pods
├─ Node 7: 19 pods
├─ Node 8: 22 pods
└─ Node 9: 23 pods
```

### LIVE DEMO 4: Pod Distribution

**Run commands:**
```bash
# Show all namespaces
kubectl get namespaces

# Pod count per namespace
kubectl get pods --all-namespaces | awk '{print $1}' | sort | uniq -c | sort -rn

# Show application pods
kubectl get pods -n digitalbank-apps -o wide

# Show pods on specific node
kubectl get pods --all-namespaces -o wide | grep "gke-digitalbank-gke-n-17ab08f8-698s"
```

**What to say:**
> "As you can see, we have pods running in multiple namespaces. The digitalbank-apps namespace contains our 4 microservices. The monitoring namespace has 25 pods for Prometheus and Grafana. Logging has 15 pods for the ELK stack. And kube-system has about 120 pods for Kubernetes core components."

### Slide 10: Why Multi-Zone?

**What to say:**
> "You might ask, why 9 nodes across 3 zones instead of 3 larger nodes in one zone? Let me explain the high availability benefits."

**Show comparison:**
```
SINGLE-ZONE DEPLOYMENT:
├─ 3 nodes in us-central1-a
└─ If data center fails: 100% downtime ❌

MULTI-ZONE DEPLOYMENT (My Choice):
├─ 3 nodes in us-central1-a
├─ 3 nodes in us-central1-b
└─ 3 nodes in us-central1-c

If us-central1-a fails:
├─ 3 nodes down (33% capacity)
├─ 6 nodes still running (66% capacity)
├─ Kubernetes auto-reschedules pods
└─ Application stays online! ✅

Google SLA:
├─ Single-zone: 99.5% uptime (43 hours downtime/year)
└─ Multi-zone: 99.95% uptime (4.4 hours downtime/year)
```

---

## 🏦 SECTION 4: Microservices Architecture (10 minutes)

### Slide 11: Microservices Overview

**What to say:**
> "The application follows a microservices architecture pattern. Instead of one monolithic application, I have 4 independent services, each with its own database."

**Show architecture:**
```
USER BROWSER
     │
     ↓
NGINX INGRESS (LoadBalancer IP: 34.31.22.16)
     │
     ├──→ Frontend (React) → Port 80
     │
     ├──→ /api/auth → Auth API (Node.js) → Port 3001
     │                   ↓
     │              Auth Database (PostgreSQL)
     │
     ├──→ /api/accounts → Accounts API (Node.js) → Port 3002
     │                       ↓
     │                  Accounts Database (PostgreSQL)
     │
     └──→ /api/transactions → Transactions API (Node.js) → Port 3003
                                ↓
                           Transactions Database (PostgreSQL)
```

### Slide 12: Why Microservices?

**What to say:**
> "I chose microservices over a monolith for several critical reasons. Let me show you a real-world scenario."

**Show comparison:**
```
SCENARIO: Black Friday - Heavy transaction load

MONOLITHIC APPROACH:
└─ Single application handles everything
    ├─ Transactions slow? Scale entire app
    ├─ Need 10 servers for transactions
    └─ But also get 10x auth, 10x accounts (don't need!)
    
    💰 Cost: $1,000/month for over-provisioned resources

MICROSERVICES APPROACH (My Implementation):
├─ Auth API: Normal load → 1 replica → $50/month
├─ Accounts API: Normal load → 1 replica → $50/month
└─ Transactions API: High load → 10 replicas → $500/month

💰 Cost: $600/month (40% savings!)

Plus additional benefits:
✅ Auth/Accounts stay fast (not affected by slow transactions)
✅ Can use different technologies per service
✅ Independent deployment schedules
✅ Teams work independently
```

### LIVE DEMO 5: Microservices in Action

**Run commands:**
```bash
# Show all deployments
kubectl get deployments -n digitalbank-apps -o wide

# Show services
kubectl get svc -n digitalbank-apps

# Show ingress routing
kubectl describe ingress digitalbank-api-ingress -n digitalbank-apps | grep -A 10 "Rules:"

# Show one service in detail
kubectl describe deployment auth-api -n digitalbank-apps
```

**What to say:**
> "Here you can see the four deployments, each running independently. The ingress controller routes traffic based on URL paths. Notice each service has its own Docker image and can be updated independently."

### Slide 13: Database-per-Service Pattern

**What to say:**
> "Each microservice has its own dedicated database. This is crucial for true service independence."

**Show pattern:**
```
WHY SEPARATE DATABASES?

BAD PATTERN (Shared Database):
┌─────────────┐
│ Auth API    │─┐
│ Accounts API│─┼──→ Single Shared Database
│ Trans API   │─┘
└─────────────┘

Problems:
❌ Services tightly coupled through database schema
❌ One service can't change schema without affecting others
❌ Database becomes bottleneck
❌ Can't scale databases independently

GOOD PATTERN (Database-per-Service) - MY IMPLEMENTATION:
┌────────────┐          ┌────────────┐
│ Auth API   │────→────│ Auth DB    │
└────────────┘          └────────────┘
                        
┌────────────┐          ┌────────────┐
│Accounts API│────→────│Accounts DB │
└────────────┘          └────────────┘

┌────────────┐          ┌────────────┐
│ Trans API  │────→────│ Trans DB   │
└────────────┘          └────────────┘

Benefits:
✅ Complete service independence
✅ Each service owns its data schema
✅ Can use different database types if needed
✅ Security: Breach of one DB ≠ all data exposed
✅ Scale databases independently
```

### LIVE DEMO 6: Show Databases

**Run commands:**
```bash
# List Cloud SQL instances
gcloud sql instances list --project=charged-thought-485008-q7 \
  --format="table(name,databaseVersion,region,state)"

# Show database IPs
gcloud sql instances list --project=charged-thought-485008-q7 \
  --format="table(name,ipAddresses[0].ipAddress,ipAddresses[1].ipAddress)"
```

**What to say:**
> "Here are the three PostgreSQL 15 databases. Each has both a private IP for internal communication from the cluster, and a public IP for external access during development. In production, we primarily use the private IPs for security."

### Slide 14: Service Communication Flow

**What to say:**
> "Let me walk you through a real user flow - registering and making a transaction."

**Show flow diagram:**
```
USER REGISTRATION & TRANSACTION FLOW:

Step 1: USER REGISTRATION
Browser → POST /api/auth/register
         ↓
    Auth API receives request
         ↓
    Hash password (bcrypt)
         ↓
    Insert into Auth Database
         ↓
    Return user_id & JWT token

Step 2: CREATE ACCOUNT
Browser → POST /api/accounts (with JWT token)
         ↓
    Accounts API validates JWT token
         ↓
    Extract user_id from token
         ↓
    Create account in Accounts Database
         ↓
    Return account details

Step 3: MAKE TRANSACTION
Browser → POST /api/transactions/transfer (with JWT)
         ↓
    Transactions API validates JWT
         ↓
    START DATABASE TRANSACTION
    ├─ Verify balance in from_account
    ├─ Debit from_account
    ├─ Credit to_account
    ├─ Record transaction
    └─ COMMIT (or ROLLBACK if any step fails)
         ↓
    Return success

Key Point: Services communicate via REST APIs, never direct database access!
```

---

## ⚙️ SECTION 5: CI/CD Pipeline & DevOps Tools (10 minutes)

### Slide 15: DevOps Pipeline Overview

**What to say:**
> "I've implemented a complete CI/CD pipeline using Jenkins for continuous integration and ArgoCD for continuous deployment following GitOps principles."

**Show pipeline:**
```
DEVELOPER WORKFLOW:

1. CODE COMMIT
   Developer → git push to GitHub
   
2. JENKINS CI (Continuous Integration)
   ├─ GitHub webhook triggers Jenkins
   ├─ Jenkins pulls code
   ├─ Runs unit tests
   ├─ Builds Docker image
   ├─ Scans image for vulnerabilities (Trivy)
   ├─ Pushes to Google Container Registry
   └─ Updates image tag in Git repository

3. ARGOCD CD (Continuous Deployment)
   ├─ ArgoCD polls Git repository (every 3 min)
   ├─ Detects new image tag
   ├─ Syncs Kubernetes cluster
   ├─ Deploys new pods
   ├─ Health checks
   └─ Reports sync status

4. MONITORING
   ├─ Prometheus scrapes metrics
   ├─ Grafana displays dashboards
   ├─ ELK Stack collects logs
   └─ Alerts on failures

Total time from commit to production: ~10 minutes
```

### Slide 16: Jenkins Pipeline

**What to say:**
> "Let me show you the Jenkins pipeline configuration. I've defined the entire CI process as code in a Jenkinsfile."

**Show Jenkinsfile snippet:**
```groovy
pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'charged-thought-485008-q7'
        GCR_REGISTRY = 'gcr.io'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'docker build -t ${GCR_REGISTRY}/${PROJECT_ID}/auth-api:${IMAGE_TAG} ./auth-api'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'trivy image ${GCR_REGISTRY}/${PROJECT_ID}/auth-api:${IMAGE_TAG}'
            }
        }
        
        stage('Push to GCR') {
            steps {
                sh 'docker push ${GCR_REGISTRY}/${PROJECT_ID}/auth-api:${IMAGE_TAG}'
            }
        }
        
        stage('Update Manifests') {
            steps {
                sh '''
                    git checkout main
                    sed -i "s|image:.*|image: ${GCR_REGISTRY}/${PROJECT_ID}/auth-api:${IMAGE_TAG}|" k8s/deployment.yaml
                    git commit -am "Update image to ${IMAGE_TAG}"
                    git push
                '''
            }
        }
    }
}
```

### Slide 17: GitOps with ArgoCD

**What to say:**
> "ArgoCD implements GitOps - which means Git is the single source of truth for deployments. Let me explain why this is powerful."

**Show comparison:**
```
TRADITIONAL DEPLOYMENT:
Developer → kubectl apply -f deployment.yaml → Cluster
Problems:
❌ No audit trail (who deployed what?)
❌ Cluster can drift from desired state
❌ Manual kubectl access required
❌ No rollback mechanism

GITOPS WITH ARGOCD (My Implementation):
Developer → git commit → git push → GitHub
            ↓
       ArgoCD polls Git
            ↓
       Detects changes
            ↓
       Syncs cluster automatically
       
Benefits:
✅ Full audit trail in Git
✅ Cluster always matches Git (self-healing)
✅ No kubectl access needed
✅ Easy rollback (git revert)
✅ Code review before deployment
```

### LIVE DEMO 7: Show Jenkins & ArgoCD

**Open Jenkins:**
```
URL: http://34.29.9.149
```

**What to say:**
> "Here's the Jenkins dashboard. You can see the build history for all microservices. Each build goes through the stages we defined: build, test, security scan, push, and update manifests."

**Open ArgoCD:**
```
URL: http://argocd.digitalbank.local
Username: admin
Password: PJm6W1MKJDOEv9en
```

**What to say:**
> "This is ArgoCD. Here you can see the digitalbank application. The green 'Synced' status means the cluster matches Git. The 'Healthy' status means all pods are running. If I were to manually change something in the cluster with kubectl, ArgoCD would revert it within 3 minutes."

**Click on the application to show the visual graph:**
> "ArgoCD provides this visual representation of all Kubernetes resources. You can see the deployments, services, pods, and their relationships."

---

## 📊 SECTION 6: Monitoring & Logging Stack (5 minutes)

### Slide 18: Observability Stack

**What to say:**
> "I've implemented a complete observability stack - metrics with Prometheus and Grafana, and logs with the ELK stack."

**Show stack:**
```
MONITORING (Prometheus + Grafana)
├─ Prometheus: Scrapes metrics every 15 seconds
│  ├─ Node metrics (CPU, memory, disk)
│  ├─ Pod metrics (container resources)
│  └─ Application metrics (HTTP requests, errors)
├─ Grafana: Visualizes metrics
│  ├─ Pre-built Kubernetes dashboards
│  ├─ Custom application dashboards
│  └─ Alerting rules
└─ Data retention: 15 days

LOGGING (ELK Stack)
├─ Filebeat: Collects logs from all containers (9 pods, one per node)
├─ Logstash: Parses and enriches logs
├─ Elasticsearch: Stores and indexes logs (3-node cluster, 90GB storage)
├─ Kibana: Log search and visualization
└─ Log retention: 7 days

Total monitoring pods: 40
Total storage: 100GB
```

### LIVE DEMO 8: Show Grafana

**Open Grafana:**
```
URL: http://grafana.digitalbank.local
Username: admin
Password: admin123
```

**What to say:**
> "This is Grafana showing real-time metrics from the cluster. This dashboard shows CPU and memory usage across all nodes, pod distribution, and resource utilization."

**Navigate to different dashboards:**
1. Kubernetes / Compute Resources / Cluster
2. Kubernetes / Compute Resources / Namespace (select digitalbank-apps)
3. Kubernetes / Compute Resources / Pod (select auth-api pod)

**Point out key metrics:**
> "Here you can see the auth-api is using about 50MB of memory and minimal CPU. The spikes you see correlate with actual user traffic. If CPU exceeds 80%, the Horizontal Pod Autoscaler would automatically scale up replicas."

### LIVE DEMO 9: Show Kibana (if time permits)

**Open Kibana:**
```
URL: http://kibana.digitalbank.local
```

**What to say:**
> "Kibana provides centralized logging. I can search across all application logs in one place. Let me show you a search for all authentication events."

**Run search:**
```
kubernetes.namespace: "digitalbank-apps" AND kubernetes.pod.name: "auth-api*"
```

---

## 🎯 SECTION 7: Live Demo & Q&A (5 minutes)

### LIVE DEMO 10: End-to-End User Flow

**What to say:**
> "Let me demonstrate the application working end-to-end, from registration to making a transaction."

**Open Frontend:**
```
URL: http://34.31.22.16
```

**Demo steps:**

**1. Register User:**
```
Click "Register"
Email: demo@presentation.com
Password: Demo123!
First Name: Demo
Last Name: User
Click "Sign Up"
```

**What to say:**
> "Behind the scenes, this POST request went through the Nginx Ingress to the Auth API pod, which hashed the password with bcrypt and stored it in the Auth PostgreSQL database. It returned a JWT token that's now stored in the browser."

**2. View Accounts:**
```
Click "Accounts"
```

**What to say:**
> "The frontend is sending the JWT token with each request. The Accounts API validates the token, extracts the user ID, and queries the Accounts database."

**3. Make a Transaction:**
```
Click "Transfer"
From Account: [select]
To Account: [select]
Amount: 100
Click "Transfer"
```

**What to say:**
> "This triggers a database transaction in the Transactions database. It verifies the balance, debits the source account, credits the destination account, and records the transaction - all atomically. If any step fails, it rolls back."

### Show Real-Time Monitoring

**Switch to Grafana:**
> "If we look at Grafana right now, you can see the spike in HTTP requests from the demo we just did. The response time was under 100ms."

**Switch to Kibana:**
> "And in Kibana, we can see the log entries for the registration and transaction we just performed."

### Final Architecture Slide

**What to say:**
> "To summarize: I built this entire platform from scratch using Infrastructure as Code with Terraform, deployed on a highly available multi-zone Kubernetes cluster with 9 nodes, implemented a microservices architecture with 4 services and 3 databases, set up a complete CI/CD pipeline with Jenkins and ArgoCD, and added full observability with Prometheus, Grafana, and ELK. The entire infrastructure is managed through code and GitOps principles."

**Show final stats:**
```
PROJECT SUMMARY:

Infrastructure:
├─ 35 Terraform-managed resources
├─ 3 availability zones
├─ 9 Kubernetes nodes
├─ 180+ pods
└─ Monthly cost: $383 USD

Application:
├─ 4 microservices
├─ 3 PostgreSQL databases
├─ React frontend
└─ Node.js backend APIs

DevOps:
├─ Jenkins CI pipeline
├─ ArgoCD GitOps deployment
├─ Prometheus + Grafana monitoring
├─ ELK Stack logging
└─ Automated scaling

Security:
├─ Private VPC
├─ Cloud NAT
├─ SSL encryption
├─ Firewall rules
└─ Container scanning

Code Statistics:
├─ 2,500+ lines of Terraform
├─ 5,000+ lines of application code
├─ 1,000+ lines of Kubernetes manifests
└─ Fully documented
```

---

## 🎤 Q&A Section (Remaining Time)

### Common Questions & Answers

**Q: Why did you choose GCP over AWS or Azure?**
> "I chose GCP for several reasons: GKE is Google's native Kubernetes (they created Kubernetes), excellent integration between services, generous free tier for learning, and the gcloud CLI is very intuitive. However, the architecture I built is cloud-agnostic - I could recreate this on AWS EKS or Azure AKS by just changing the Terraform provider."

**Q: How do you handle database backups?**
> "Cloud SQL automatically backs up the databases daily at 3 AM, 4 AM, and 5 AM respectively. Backups are retained for 7 days. I can restore to any point in time within that window. Additionally, the Terraform state contains all database configurations, so I can recreate from scratch if needed."

**Q: What happens if a node fails?**
> "Kubernetes automatically detects the node failure and reschedules all pods to healthy nodes. Since I have 9 nodes across 3 zones, losing one node only impacts 11% of capacity. The autoscaler will provision a new node within 5 minutes."

**Q: How do you handle secrets?**
> "Database passwords are generated by Terraform using the random_password provider and stored in Google Secret Manager. Kubernetes pulls secrets at runtime using Workload Identity. JWT secrets are stored as Kubernetes Secrets. No secrets are committed to Git."

**Q: What's the cost to run this?**
> "Currently $383/month, broken down as: GKE cluster ~$150, 3 Cloud SQL instances ~$180, networking ~$25, storage ~$15, and monitoring ~$13. This is optimized for demo/development. Production would cost more with larger instances and REGIONAL databases."

**Q: How long did this take to build?**
> "The initial infrastructure took about 2 weeks of planning and implementation. The application development was another 3 weeks. Setting up CI/CD and monitoring added 1 week. Total: about 6 weeks from conception to production-ready."

**Q: Can this scale to handle millions of users?**
> "Absolutely. The autoscaler can expand to 30 nodes, and I can increase node size. Horizontal Pod Autoscaler will scale replicas based on CPU/memory. Databases can be upgraded to larger instance types. The architecture supports scaling to millions of users - it's just a matter of budget."

---

## 📝 Presentation Tips

### Timing Management
- **5 min intro** - Keep it concise, get to technical content quickly
- **15 min Terraform** - Most important, show the code
- **10 min GKE** - Show the actual cluster running
- **10 min Microservices** - Explain architecture decisions
- **10 min DevOps** - Show Jenkins & ArgoCD in action
- **5 min Monitoring** - Quick Grafana/Kibana demo
- **5 min Demo** - End-to-end user flow
- **Reserve time for Q&A**

### What to Have Open Before Starting
1. Terminal with kubectl connected
2. Grafana dashboard
3. ArgoCD dashboard
4. Frontend application
5. VS Code with terraform files
6. This presentation guide

### Commands to Test Before Presenting
```bash
# Verify connectivity
gcloud config get-value project
kubectl get nodes
curl http://34.31.22.16

# Test all URLs
curl http://grafana.digitalbank.local
curl http://argocd.digitalbank.local
```

### Backup Plans
- If live demo fails: Have screenshots/video
- If internet is slow: Have offline diagrams
- If questions run over: Skip the Kibana demo

---

**Good luck with your presentation! You've built an impressive production-grade platform from scratch!**
