# 🎯 Live Demo Commands - Digital Banking Platform

**Purpose**: Commands to run during presentation to showcase the infrastructure

---

## 📋 Pre-Demo Checklist

```bash
# 1. Verify you're logged into correct GCP project
gcloud config get-value project
# Should show: charged-thought-485008-q7

# 2. Verify kubectl context
kubectl config current-context
# Should show: gke_charged-thought-485008-q7_us-central1_digitalbank-gke

# 3. Test internet connectivity
curl -s http://34.31.22.16 | head -5
# Should return HTML (frontend is up)
```

---

## 🎬 Demo Flow

### PART 1: Infrastructure Overview (5 minutes)

#### Show GKE Cluster Details
```bash
# Show cluster info
gcloud container clusters describe digitalbank-gke --region us-central1 --format="table(name,location,currentMasterVersion,currentNodeCount,status)"

# Alternative: Detailed cluster view
gcloud container clusters list --format="table(name,location,currentMasterVersion,currentNodeCount,status)"
```

**What to say:**
> "We have a production GKE cluster running in us-central1 across 3 availability zones for high availability."

#### Show All Nodes
```bash
# Show nodes across zones
kubectl get nodes -o wide

# Or with better formatting
kubectl get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,ZONE:.metadata.labels.topology\.kubernetes\.io/zone,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,INTERNAL-IP:.status.addresses[0].address
```

**What to say:**
> "Here are our 3 worker nodes, one in each zone (a, b, c). Each node is an e2-standard-2 with 2 vCPUs and 8GB RAM."

#### Show Resource Usage
```bash
# Node resource consumption
kubectl top nodes

# If metrics server isn't ready, show this instead:
kubectl describe nodes | grep -A 5 "Allocated resources"
```

**What to say:**
> "Current CPU and memory usage across our nodes. You can see we're running efficiently with room to scale."

---

### PART 2: Application Stack (7 minutes)

#### Show All Namespaces
```bash
# List all namespaces
kubectl get namespaces

# Show pod count per namespace
kubectl get pods --all-namespaces | awk '{print $1}' | sort | uniq -c | sort -rn
```

**What to say:**
> "Our platform is organized into namespaces: digitalbank-apps for our microservices, digitalbank-monitoring for observability, and others for supporting infrastructure."

#### Show Application Deployments
```bash
# Show deployments in digitalbank-apps namespace
kubectl get deployments -n digitalbank-apps -o wide

# More detailed view with replicas
kubectl get deployments -n digitalbank-apps -o custom-columns=NAME:.metadata.name,READY:.status.readyReplicas,AVAILABLE:.status.availableReplicas,IMAGE:.spec.template.spec.containers[0].image
```

**What to say:**
> "Here are our 4 microservices: auth-api, accounts-api, transactions-api, and the frontend. Each is running with 1 replica, optimized for our demo environment."

#### Show Running Pods
```bash
# Show all application pods
kubectl get pods -n digitalbank-apps -o wide

# Show pod status and which node they're on
kubectl get pods -n digitalbank-apps -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName,IP:.status.podIP
```

**What to say:**
> "Each microservice runs in a container (pod) with its own IP address, distributed across our nodes for redundancy."

#### Show Services (Internal Load Balancing)
```bash
# Show services in digitalbank-apps
kubectl get svc -n digitalbank-apps

# Or more detailed
kubectl get svc -n digitalbank-apps -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,PORT:.spec.ports[0].port
```

**What to say:**
> "Kubernetes Services provide stable endpoints. Even if pods restart and get new IPs, services ensure other microservices can find them."

#### Show Ingress (External Access)
```bash
# Show ingress configuration
kubectl get ingress -n digitalbank-apps

# Detailed view with routes
kubectl describe ingress digitalbank-api-ingress -n digitalbank-apps | grep -A 20 "Rules:"
```

**What to say:**
> "Our Nginx Ingress routes traffic based on URL paths. All traffic comes through one LoadBalancer IP (34.31.22.16), then routes to the correct microservice."

---

### PART 3: Databases (5 minutes)

#### Show Cloud SQL Instances
```bash
# List all databases
gcloud sql instances list --project=charged-thought-485008-q7 --format="table(name,databaseVersion,region,gceZone,settings.tier,state)"

# Show detailed info for one database
gcloud sql instances describe digitalbank-auth-db --project=charged-thought-485008-q7 --format="table(name,databaseVersion,settings.tier,settings.availabilityType,ipAddresses[0].ipAddress)"
```

**What to say:**
> "We have 3 PostgreSQL 15 databases - one per microservice following the database-per-service pattern. They're running in ZONAL mode for cost optimization."

#### Show Database IPs (Private + Public)
```bash
# Show both private and public IPs
gcloud sql instances list --project=charged-thought-485008-q7 --format="table(name,ipAddresses.filter(type:PRIVATE).firstof(ipAddress),ipAddresses.filter(type:PRIMARY).firstof(ipAddress))"
```

**What to say:**
> "Each database has a private IP (10.121.0.x) for secure cluster access and a public IP for DBeaver management access from our laptops."

#### Show Database Secrets in Kubernetes
```bash
# Show how credentials are stored (without revealing passwords)
kubectl get secret db-urls -n digitalbank -o jsonpath='{.data}' | jq 'keys'

# Or show the secret exists
kubectl get secret db-urls -n digitalbank
```

**What to say:**
> "Database credentials are stored as Kubernetes secrets, not in code. This follows security best practices."

---

### PART 4: Monitoring & Logging (5 minutes)

#### Show Monitoring Stack
```bash
# Show Prometheus and Grafana deployments
kubectl get deployments -n digitalbank-monitoring

# Show their services
kubectl get svc -n digitalbank-monitoring | grep -E "prometheus-grafana|prometheus-kube-prometheus-prometheus"
```

**What to say:**
> "Our monitoring stack: Prometheus collects metrics every 30 seconds, Grafana visualizes them with dashboards."

#### Show Logging Stack
```bash
# Show ELK stack pods
kubectl get pods -n elk-demo

# Show Filebeat DaemonSet (runs on every node)
kubectl get daemonset -n elk-demo
```

**What to say:**
> "Filebeat runs on every node as a DaemonSet, collecting logs from all containers and shipping them to Elasticsearch. Kibana provides the search interface."

#### Access Grafana (Live Demo)
```bash
# Get Grafana URL
kubectl get svc prometheus-grafana -n digitalbank-monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo "http://$(kubectl get svc prometheus-grafana -n digitalbank-monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
```

**Then open in browser:**
- URL: http://136.111.5.250
- Login: admin / admin123
- Navigate to dashboards

**What to say:**
> "Let me show you a live dashboard monitoring our cluster right now..." (Show graphs, metrics)

---

### PART 5: GitOps & CI/CD (5 minutes)

#### Show ArgoCD Applications
```bash
# List ArgoCD apps
kubectl get applications -n argocd

# Show sync status
kubectl get applications -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status
```

**What to say:**
> "ArgoCD manages our deployments. These applications are continuously synced with our Git repository every 30 seconds."

#### Show ArgoCD in Browser
```bash
# Get ArgoCD URL
echo "ArgoCD: http://35.188.11.8"

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

**Then login to ArgoCD UI and show:**
- Sync status
- Application topology
- Live state vs desired state

**What to say:**
> "This is our GitOps control plane. Any change pushed to Git is automatically deployed to the cluster. Watch this sync happening..."

#### Show Git Commit History
```bash
# Show recent deployment commits
git log --oneline -10 --graph
```

**What to say:**
> "Every infrastructure change is tracked in Git. Here's our deployment history with audit trail."

---

### PART 6: Security (5 minutes)

#### Show Kyverno Policies
```bash
# List all policies
kubectl get clusterpolicies

# Show a specific policy
kubectl get clusterpolicy require-resource-limits -o yaml | grep -A 10 "spec:"
```

**What to say:**
> "Kyverno enforces security policies. For example, this policy blocks any pod without resource limits."

#### Demonstrate Policy Enforcement
```bash
# Try to create a pod without resource limits (will be blocked)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx
EOF
```

**Expected result:** Error from Kyverno blocking the pod

**What to say:**
> "Watch this - I'm trying to deploy a pod without resource limits. Kyverno blocks it automatically. This prevents accidental resource exhaustion."

#### Show Network Policies
```bash
# Show firewall rules
gcloud compute firewall-rules list --filter="network:digitalbank-vpc" --format="table(name,direction,sourceRanges.list():label=SRC_RANGES,allowed[].map().firewall_rule().list():label=ALLOW,targetTags.list():label=TARGET_TAGS)"
```

**What to say:**
> "Our VPC has firewall rules controlling traffic. Only SSH (22) and HTTP/HTTPS (80, 443) are allowed from the internet."

---

### PART 7: Live Application Demo (7 minutes)

#### Test Frontend
```bash
# Open frontend
echo "Frontend: http://34.31.22.16"

# Test it's responding
curl -I http://34.31.22.16
```

**Then open in browser and show the UI**

**What to say:**
> "Here's our live banking application. It's a React SPA communicating with our microservices."

#### Test API Endpoints
```bash
# Test Auth API - Health Check
curl http://34.31.22.16/api/auth/health | jq

# Register a user (live demo)
curl -X POST http://34.31.22.16/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "Demo123!",
    "first_name": "Demo",
    "last_name": "User"
  }' | jq

# Login
curl -X POST http://34.31.22.16/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "Demo123!"
  }' | jq

# Save the token
export TOKEN="<paste token from response>"

# Verify token
curl http://34.31.22.16/api/auth/verify \
  -H "Authorization: Bearer $TOKEN" | jq
```

**What to say:**
> "Let me register a user, log in, and get a JWT token. This hits the auth-api microservice which stores data in the auth database."

#### Create Bank Account (Microservice Communication)
```bash
# Create account (requires token from above)
curl -X POST http://34.31.22.16/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "account_type": "savings",
    "currency": "USD",
    "initial_balance": 1000
  }' | jq
```

**What to say:**
> "Now creating a bank account. Notice the accounts-api verifies the token with auth-api - this is microservice-to-microservice communication through Kubernetes services."

#### Show Logs in Real-Time
```bash
# Watch auth-api logs during API call
kubectl logs -f deployment/auth-api -n digitalbank-apps

# In another terminal, make API call
curl http://34.31.22.16/api/auth/verify -H "Authorization: Bearer $TOKEN"
```

**What to say:**
> "You can see the API call appearing in real-time logs. These same logs are collected by Filebeat and searchable in Kibana."

---

### PART 8: Infrastructure as Code (5 minutes)

#### Show Terraform State
```bash
# Show all resources managed by Terraform
cd terraform/
terraform state list

# Count resources
terraform state list | wc -l
echo "Total: 32 resources"
```

**What to say:**
> "Everything you've seen - VPC, GKE cluster, databases, networking - all created with Terraform. 32 resources defined as code."

#### Show a Terraform Resource
```bash
# Show VPC configuration
terraform state show google_compute_network.vpc

# Show GKE cluster config
terraform state show google_container_cluster.primary | head -30
```

**What to say:**
> "Here's the actual infrastructure as code. If I need to recreate this environment, I just run 'terraform apply'."

#### Show Terraform Plan (Drift Detection)
```bash
# Check if infrastructure matches code
terraform plan
```

**What to say:**
> "This checks if the actual infrastructure matches our code. No changes needed means infrastructure is in sync with code."

---

### PART 9: Scaling Demo (5 minutes)

#### Scale Application Up
```bash
# Scale auth-api from 1 to 3 replicas
kubectl scale deployment auth-api --replicas=3 -n digitalbank-apps

# Watch pods being created
kubectl get pods -n digitalbank-apps -w
# Press Ctrl+C after pods are running

# Show all 3 replicas
kubectl get pods -n digitalbank-apps -l app=auth-api -o wide
```

**What to say:**
> "Watch this - scaling from 1 to 3 replicas. Kubernetes automatically distributes pods across nodes and adds them to the load balancer."

#### Test Load Balancing
```bash
# Make multiple requests, watch which pod handles each
for i in {1..5}; do
  echo "Request $i:"
  curl -s http://34.31.22.16/api/auth/health | jq -r '.hostname'
  sleep 1
done
```

**What to say:**
> "Each request goes to a different pod - automatic load balancing. The service distributes traffic across all healthy replicas."

#### Scale Back Down
```bash
# Scale back to 1 replica
kubectl scale deployment auth-api --replicas=1 -n digitalbank-apps

# Watch termination
kubectl get pods -n digitalbank-apps -w
```

**What to say:**
> "Scaling down gracefully terminates excess pods. Kubernetes handles everything - no manual intervention needed."

---

### PART 10: Database Access (5 minutes)

#### Show Database Connection from Pod
```bash
# Exec into auth-api pod
kubectl exec -it deployment/auth-api -n digitalbank-apps -- /bin/bash

# Inside pod, connect to database
psql -h 10.121.0.2 -U authuser -d authdb -c "\dt"

# Show users table
psql -h 10.121.0.2 -U authuser -d authdb -c "SELECT id, email, first_name, last_name, created_at FROM users LIMIT 5;"

# Exit
exit
```

**What to say:**
> "From inside the pod, we can connect to the database using its private IP (10.121.0.2). This traffic never touches the internet - it's all within our VPC."

#### Show DBeaver Access (GUI)
```bash
# Show database public IPs
gcloud sql instances list --project=charged-thought-485008-q7 --format="table(name,ipAddresses.filter(type:PRIMARY).firstof(ipAddress))"
```

**Then open DBeaver and connect to show tables/data**

**What to say:**
> "For management, we can also access databases from our laptops via DBeaver using the public IP. This is restricted to our IP address only."

---

### PART 11: Monitoring Deep Dive (5 minutes)

#### Show Prometheus Targets
```bash
# Open Prometheus
echo "Prometheus: http://34.71.18.248:9090"
```

**In browser, go to:**
- Status → Targets (show all scrape targets)
- Graph → Execute query: `up` (show which services are up)
- Query: `container_memory_usage_bytes{namespace="digitalbank-apps"}` (show memory usage)

**What to say:**
> "Prometheus is scraping metrics from all our services. You can see real-time memory usage, CPU, request rates, everything."

#### Show Kibana Logs
```bash
# Open Kibana
echo "Kibana: http://34.44.185.11:5601"
```

**In browser:**
- Navigate to Discover
- Search: `kubernetes.namespace: "digitalbank-apps"`
- Show logs from all microservices

**What to say:**
> "All application logs are centralized here. I can search across all 90+ pods instantly."

---

## 🎯 Impressive One-Liners for Demo

```bash
# Show everything at once - "The Money Shot"
echo "=== CLUSTER ===" && kubectl get nodes && \
echo -e "\n=== APPLICATIONS ===" && kubectl get pods -n digitalbank-apps && \
echo -e "\n=== DATABASES ===" && gcloud sql instances list --project=charged-thought-485008-q7 && \
echo -e "\n=== SERVICES ===" && kubectl get svc --all-namespaces | grep LoadBalancer

# Show total pod count
echo "Total pods running: $(kubectl get pods --all-namespaces --no-headers | wc -l)"

# Show resource utilization
kubectl top nodes && echo && kubectl top pods -n digitalbank-apps

# Show complete stack in one view
kubectl get all -n digitalbank-apps

# Show external access points
echo "=== PUBLIC ENDPOINTS ===" && \
echo "Frontend:     http://$(kubectl get svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" && \
echo "Grafana:      http://$(kubectl get svc prometheus-grafana -n digitalbank-monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" && \
echo "Prometheus:   http://$(kubectl get svc prometheus-kube-prometheus-prometheus -n digitalbank-monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):9090" && \
echo "Kibana:       http://$(kubectl get svc kibana -n elk-demo -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):5601" && \
echo "ArgoCD:       http://$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
```

---

## 🚨 Troubleshooting During Demo

### If pods aren't running:
```bash
kubectl get pods -n digitalbank-apps
kubectl describe pod <pod-name> -n digitalbank-apps
kubectl logs <pod-name> -n digitalbank-apps
```

### If API calls fail:
```bash
# Check ingress
kubectl get ingress -n digitalbank-apps
kubectl describe ingress digitalbank-api-ingress -n digitalbank-apps

# Check service endpoints
kubectl get endpoints auth-api -n digitalbank-apps
```

### If database connection fails:
```bash
# Check database is running
gcloud sql instances list --project=charged-thought-485008-q7

# Check VPC peering
gcloud services vpc-peerings list --network=digitalbank-vpc
```

---

## 📝 Demo Tips

1. **Practice the flow** - Run through this script 2-3 times before presenting
2. **Have URLs ready** - Bookmark all the service URLs in your browser
3. **Terminal setup** - Use split terminals or tmux to show multiple things
4. **Prepare cleanup** - Delete the demo user after showing creation
5. **Backup screenshots** - In case of network issues, have screenshots ready
6. **Know your times** - This full demo is ~50-60 minutes. Adjust based on your time slot.

**Short demo (15 min):** Parts 1, 2, 7, 9
**Medium demo (30 min):** Parts 1, 2, 5, 7, 9, 10
**Full demo (60 min):** All parts

---

**Last Updated:** January 29, 2026
