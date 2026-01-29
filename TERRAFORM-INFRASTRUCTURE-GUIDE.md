# 🏗️ Terraform Infrastructure - Complete Guide

## 📋 Overview

**Current Infrastructure State:**
- **GCP Project**: charged-thought-485008-q7
- **Region**: us-central1
- **Total Resources**: 32 Terraform-managed resources
- **Monthly Cost**: ~$383/month (optimized for demo)

---

## 🗂️ Resource Inventory

### Network Layer (7 resources)

| Resource | Name | Purpose |
|----------|------|---------|
| `google_compute_network.vpc` | digitalbank-vpc | Isolated VPC for entire platform |
| `google_compute_subnetwork.subnet` | digitalbank-subnet | Primary subnet with 3 IP ranges |
| `google_compute_router.router` | digitalbank-vpc-router | Required for Cloud NAT |
| `google_compute_router_nat.nat` | digitalbank-vpc-nat | Outbound internet for private nodes |
| `google_compute_firewall.allow_ssh` | allow-ssh | SSH access to GKE nodes |
| `google_compute_firewall.allow_http_https` | allow-http-https | Web traffic to LoadBalancers |
| `google_compute_global_address.private_ip_address` | digitalbank-private-ip | IP range for Cloud SQL private IPs |

### Compute Layer (2 resources)

| Resource | Name | Purpose |
|----------|------|---------|
| `google_container_cluster.primary` | digitalbank-gke | GKE cluster control plane |
| `google_container_node_pool.primary_nodes` | digitalbank-gke-node-pool | Worker nodes (currently 3 nodes) |

### Database Layer (15 resources)

**3 Cloud SQL Instances:**
| Resource | Name | Type | Availability |
|----------|------|------|--------------|
| `google_sql_database_instance.auth` | digitalbank-auth-db | PostgreSQL 15 | ZONAL |
| `google_sql_database_instance.accounts` | digitalbank-accounts-db | PostgreSQL 15 | ZONAL |
| `google_sql_database_instance.transactions` | digitalbank-transactions-db | PostgreSQL 15 | ZONAL |

**3 Databases:**
- `google_sql_database.auth_db` → authdb
- `google_sql_database.accounts_db` → accountsdb
- `google_sql_database.transactions_db` → transactionsdb

**3 Database Users:**
- `google_sql_user.auth_user` → authuser
- `google_sql_user.accounts_user` → accountsuser
- `google_sql_user.transactions_user` → transactionsuser

**6 Random Passwords:**
- `random_password.auth_db_password` → Auth DB password
- `random_password.accounts_db_password` → Accounts DB password
- `random_password.transactions_db_password` → Transactions DB password
- Plus 3 root user passwords (not used)

### Service Networking (2 resources)

| Resource | Name | Purpose |
|----------|------|---------|
| `google_service_networking_connection.private_vpc_connection` | servicenetworking | Connects VPC to Cloud SQL |
| `google_compute_global_address.private_ip_address` | digitalbank-private-ip | Reserves IPs for databases |

### State Storage (1 resource)

| Resource | Name | Purpose |
|----------|------|---------|
| `google_storage_bucket.terraform_state` | digitalbank-terraform-state | Stores Terraform state remotely |

### Data Sources (5 resources)

These don't create resources, they fetch information:
- `data.google_client_config.default` - Current GCP config
- `data.google_compute_zones.available` - Available zones in region
- Various lookups for project info

---

## 🌐 Network Architecture

### VPC & Subnets

```hcl
VPC: digitalbank-vpc
├── Subnet: digitalbank-subnet (10.0.0.0/24)
│   ├── Primary Range: 10.0.0.0/24 (256 IPs for nodes)
│   ├── Pods Range: 10.1.0.0/16 (65,536 IPs for pods)
│   └── Services Range: 10.2.0.0/16 (65,536 IPs for services)
│
├── Cloud Router: digitalbank-vpc-router
│   └── Cloud NAT: digitalbank-vpc-nat
│       └── Enables private nodes to access internet
│
└── Private Service Connection
    └── IP Range: 10.121.0.0/16 (for Cloud SQL private IPs)
```

**Why 3 IP Ranges?**

1. **Primary (10.0.0.0/24)** - GKE node IPs
   ```
   Example: gke-digitalbank-node-abc123 → 10.0.0.12
   ```

2. **Pods (10.1.0.0/16)** - Pod IPs (alias IP)
   ```
   Example: auth-api-5dfdf8556b-2czrq → 10.1.3.14
   ```

3. **Services (10.2.0.0/16)** - ClusterIP service IPs
   ```
   Example: auth-api service → 10.2.171.160
   ```

### Current IP Allocations

| Type | CIDR | Allocated | Available |
|------|------|-----------|-----------|
| Nodes | 10.0.0.0/24 | 3 IPs | 253 IPs |
| Pods | 10.1.0.0/16 | ~90 IPs | 65,446 IPs |
| Services | 10.2.0.0/16 | ~50 IPs | 65,486 IPs |
| Cloud SQL | 10.121.0.0/16 | 3 IPs | 65,533 IPs |

### Firewall Rules

**1. allow-ssh**
```hcl
Ports: 22
Source: 0.0.0.0/0
Target: All instances in VPC
Purpose: Administrative access
```

**2. allow-http-https**
```hcl
Ports: 80, 443
Source: 0.0.0.0/0
Target: All instances in VPC
Purpose: Public web traffic
```

**3. GKE-managed rules** (auto-created)
- Node to node communication
- Pod to pod communication
- Master to node communication

---

## ⚙️ GKE Cluster Configuration

### Cluster Details

```hcl
Name: digitalbank-gke
Region: us-central1
Zones: us-central1-a, us-central1-b, us-central1-c
Network: digitalbank-vpc
Subnetwork: digitalbank-subnet

Features:
├── VPC-Native Networking: Enabled
├── Private Nodes: Enabled (no public IPs on nodes)
├── Private Endpoint: Disabled (public control plane)
├── Workload Identity: Enabled
├── Binary Authorization: Disabled
├── Network Policy: Enabled (Calico)
└── HTTP Load Balancing: Enabled
```

### Node Pool

```hcl
Name: digitalbank-gke-node-pool
Machine Type: e2-standard-2
  ├── vCPUs: 2
  ├── Memory: 8 GB
  └── Disk: 100 GB SSD

Nodes per Zone: 1
Total Nodes: 3 (1 per zone)

Auto-scaling: Disabled
Auto-repair: Enabled
Auto-upgrade: Enabled

Cost: ~$75/month
```

**Node Distribution:**
```
us-central1-a: 1 node (gke-digitalbank-gke-...)
us-central1-b: 1 node (gke-digitalbank-gke-...)
us-central1-c: 1 node (gke-digitalbank-gke-...)
```

---

## 🗄️ Database Infrastructure

### Cloud SQL Configuration

**Common Settings (All 3 Databases):**
```hcl
Database Version: POSTGRES_15
Tier: db-n1-standard-1
  ├── vCPUs: 1
  ├── Memory: 3.75 GB
  └── Cost: ~$65/month each

Storage:
  ├── Size: 20 GB
  ├── Type: PD_SSD
  ├── Auto-resize: Enabled
  └── Auto-resize limit: 100 GB

Availability: ZONAL (changed from REGIONAL for cost savings)
Region: us-central1

Backup:
  ├── Enabled: Yes
  ├── Start time: 03:00 UTC
  ├── Retention: 7 days
  ├── Point-in-time recovery: Enabled
  └── Transaction log retention: 7 days

Maintenance:
  ├── Window: Sunday 03:00-04:00 UTC
  └── Update track: stable
```

### Database Instances

**1. Auth Database**
```hcl
Instance: digitalbank-auth-db
Database: authdb
User: authuser
Password: [auto-generated, 32 chars]

IPs:
├── Private: 10.121.0.2
└── Public: 34.72.18.102 (enabled for DBeaver)

Tables: users
```

**2. Accounts Database**
```hcl
Instance: digitalbank-accounts-db
Database: accountsdb
User: accountsuser
Password: [auto-generated, 32 chars]

IPs:
├── Private: 10.121.0.3
└── Public: 34.68.74.165 (enabled for DBeaver)

Tables: accounts
```

**3. Transactions Database**
```hcl
Instance: digitalbank-transactions-db
Database: transactionsdb
User: transactionsuser
Password: [auto-generated, 32 chars]

IPs:
├── Private: 10.121.0.4
└── Public: 34.30.204.132 (enabled for DBeaver)

Tables: transactions
```

### Private IP Setup

**Service Networking Connection:**
```hcl
resource "google_service_networking_connection" "private_vpc_connection" {
  network = google_compute_network.vpc.id
  service = "servicenetworking.googleapis.com"
  
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_address.name
  ]
}

# Reserved IP range for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "digitalbank-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}
```

**Why This Exists:**
- Cloud SQL needs a peered VPC connection
- Allocates 10.121.0.0/16 for database private IPs
- Allows GKE pods to connect to databases via private IPs (10.121.0.x)
- No data traverses public internet

---

## 🔐 Security Configuration

### 1. Network Security

**Private Nodes:**
```hcl
ip_allocation_policy {
  cluster_ipv4_cidr_block  = "10.1.0.0/16"  # Pods
  services_ipv4_cidr_block = "10.2.0.0/16"  # Services
}

private_cluster_config {
  enable_private_nodes    = true   # Nodes have no public IPs
  enable_private_endpoint = false  # Master endpoint is public
  master_ipv4_cidr_block  = "172.16.0.0/28"
}
```

**Cloud NAT:**
- Private nodes can't access internet directly
- Cloud NAT provides outbound connectivity
- Allows pulling images from Docker Hub, GCR
- No inbound connections allowed

### 2. Database Security

**Flags:**
```hcl
database_flags = [
  { name = "log_checkpoints",              value = "on" },
  { name = "log_connections",              value = "on" },
  { name = "log_disconnections",           value = "on" },
  { name = "log_lock_waits",               value = "on" },
  { name = "max_connections",              value = "100" },
  { name = "shared_buffers",               value = "262144" },  # 2GB
  { name = "effective_cache_size",         value = "1048576" }, # 8GB
  { name = "maintenance_work_mem",         value = "262144" },  # 256MB
  { name = "checkpoint_completion_target", value = "0.9" },
]
```

**Connection Security:**
- Private IP (10.121.0.x) for cluster connections
- Public IP (34.x.x.x) restricted to your IP for DBeaver
- SSL optional (disabled for testing)
- Passwords stored in Kubernetes secrets

---

## 💰 Cost Analysis

### Current Monthly Costs

| Component | Quantity | Unit Cost | Total |
|-----------|----------|-----------|-------|
| **GKE Nodes** | 3 × e2-standard-2 | $25/node | $75 |
| **Cloud SQL (Auth)** | 1 × db-n1-standard-1, ZONAL | $65/instance | $65 |
| **Cloud SQL (Accounts)** | 1 × db-n1-standard-1, ZONAL | $65/instance | $65 |
| **Cloud SQL (Transactions)** | 1 × db-n1-standard-1, ZONAL | $65/instance | $65 |
| **LoadBalancers** | 6 × $18/month | $18/LB | $108 |
| **Storage (PV + Backups)** | Various | - | $5 |
| **Network Egress** | Minimal (private networking) | - | $5 |
| **Total** | | | **~$383/month** |

### Cost Optimization History

| Change | Before | After | Savings |
|--------|--------|-------|---------|
| Nodes 9→3 | $220/mo | $75/mo | -$145/mo |
| DB REGIONAL→ZONAL | $600/mo | $200/mo | -$400/mo |
| Replicas 2→1 | - | - | Compute savings |

**Further Optimization Options:**
1. **Consolidate LoadBalancers**: Use single Ingress → Save $90/month
2. **Smaller DB instances**: db-f1-micro → Save $120/month (but slower)
3. **Reduce backup retention**: 7 days → 3 days → Save $10/month
4. **Use preemptible nodes**: 70% discount → Save $50/month (but less reliable)

---

## 🔄 Resource Dependencies

### Dependency Graph

```
google_compute_network.vpc
    ↓
google_compute_subnetwork.subnet
    ↓
    ├─→ google_compute_router.router
    │       ↓
    │   google_compute_router_nat.nat
    │
    ├─→ google_compute_global_address.private_ip_address
    │       ↓
    │   google_service_networking_connection.private_vpc_connection
    │       ↓
    │   google_sql_database_instance.* (3 instances)
    │       ↓
    │   google_sql_database.* (3 databases)
    │       ↓
    │   google_sql_user.* (3 users)
    │
    └─→ google_container_cluster.primary
            ↓
        google_container_node_pool.primary_nodes
```

**Critical Path:**
1. VPC must exist first
2. Subnet requires VPC
3. Private IP allocation requires VPC
4. Service connection requires private IP
5. Cloud SQL requires service connection
6. GKE cluster requires subnet

**Terraform Apply Order:**
```bash
# Terraform automatically handles this order:
1. Create VPC
2. Create subnet
3. Create router & NAT
4. Reserve private IP range
5. Create service connection
6. Create GKE cluster
7. Create Cloud SQL instances
8. Create databases & users
```

---

## 📝 Terraform Commands

### Initialize & Plan

```bash
# Initialize Terraform
cd terraform/
terraform init

# View execution plan
terraform plan

# Apply with auto-approve
terraform apply -auto-approve
```

### State Management

```bash
# View current state
terraform show

# List all resources
terraform state list

# View specific resource
terraform state show google_container_cluster.primary

# Remove resource from state (danger!)
terraform state rm google_sql_database_instance.auth
```

### Import Existing Resources

```bash
# If resources were created manually, import them:
terraform import google_container_cluster.primary projects/PROJECT_ID/locations/REGION/clusters/CLUSTER_NAME
terraform import google_sql_database_instance.auth projects/PROJECT_ID/instances/INSTANCE_NAME
```

### Outputs

```bash
# View all outputs
terraform output

# Specific output
terraform output gke_cluster_name
terraform output database_connection_names
```

---

## 🛠️ Maintenance Tasks

### Scaling Nodes

**To change node count, update terraform/main.tf:**
```hcl
resource "google_container_node_pool" "primary_nodes" {
  node_count = 1  # Change this (per zone)
  # ...
}
```

Then apply:
```bash
terraform apply
# Or via gcloud for quick changes:
gcloud container clusters resize digitalbank-gke \
  --node-pool digitalbank-gke-node-pool \
  --num-nodes 2 \
  --region us-central1
```

### Upgrading Kubernetes

```bash
# Check available versions
gcloud container get-server-config --region us-central1

# Upgrade control plane (via Terraform)
# Edit terraform/main.tf:
resource "google_container_cluster" "primary" {
  min_master_version = "1.28.5-gke.1000"  # Update version
}

terraform apply

# Node pool auto-upgrades separately (enabled by default)
```

### Database Maintenance

**Change database tier:**
```hcl
resource "google_sql_database_instance" "auth" {
  settings {
    tier = "db-n1-standard-2"  # Upgrade from standard-1
  }
}
```

**Enable High Availability:**
```hcl
resource "google_sql_database_instance" "auth" {
  settings {
    availability_type = "REGIONAL"  # Change from ZONAL
  }
}
```

---

## 🚨 Troubleshooting

### Common Issues

**1. Quota Exceeded**
```bash
Error: Error creating InstanceGroupManager: googleapi: Error 403: Quota 'INSTANCE_GROUPS' exceeded

Solution:
gcloud compute project-info describe --project=PROJECT_ID
# Request quota increase in GCP Console
```

**2. IP Range Exhaustion**
```bash
Error: Pod CIDR is exhausted

Solution:
# Expand pod IP range in terraform/main.tf:
secondary_ip_range {
  range_name    = "pods"
  ip_cidr_range = "10.1.0.0/14"  # Expands from /16
}
```

**3. Database Connection Timeout**
```bash
Error: dial tcp 10.121.0.2:5432: i/o timeout

Check:
1. Service networking connection exists
2. VPC peering is active
3. Firewall rules allow traffic
4. Database is running (not updating)
```

**4. Terraform State Lock**
```bash
Error: Error acquiring the state lock

Solution:
# Force unlock (use with caution!)
terraform force-unlock LOCK_ID
```

---

## 📚 Additional Resources

### Terraform State

**Backend Configuration:**
```hcl
terraform {
  backend "gcs" {
    bucket = "digitalbank-terraform-state"
    prefix = "terraform/state"
  }
}
```

**State Location:**
```
gs://digitalbank-terraform-state/terraform/state/default.tfstate
```

### Generated Secrets

**Database passwords stored in:**
```bash
# Kubernetes secret
kubectl get secret db-urls -n digitalbank -o yaml

# Base64 decode to view:
echo "encoded_password" | base64 -d
```

---

## 📖 Summary

### What Terraform Manages

✅ **Network** - VPC, subnets, NAT, firewall rules  
✅ **Compute** - GKE cluster + node pool  
✅ **Databases** - 3 Cloud SQL instances with all configs  
✅ **Service Networking** - Private connectivity for Cloud SQL  
✅ **State Storage** - GCS bucket for Terraform state  

### What Terraform Does NOT Manage

❌ **Kubernetes Resources** - Managed by ArgoCD (deployments, services, ingress)  
❌ **Application Code** - Managed in Git repository  
❌ **Container Images** - Built by Jenkins, stored in Container Registry  
❌ **Monitoring Stack** - Deployed via Helm charts  
❌ **SSL Certificates** - Not yet configured  

---

**Last Updated:** January 29, 2026  
**Terraform Version:** 1.x  
**Provider Version:** google ~> 5.0
