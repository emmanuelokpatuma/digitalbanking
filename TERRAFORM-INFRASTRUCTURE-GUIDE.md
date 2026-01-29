+-# 🏗️ Terraform Infrastructure - Complete Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Network Infrastructure](#network-infrastructure)
3. [GKE Cluster](#gke-cluster)
4. [Database Layer](#database-layer)
5. [Integration & Dependencies](#integration--dependencies)
6. [Resource Flow Diagram](#resource-flow-diagram)
7. [Why Each Resource Exists](#why-each-resource-exists)

---

## Overview

**Terraform manages ALL your GCP infrastructure** - 32 resources total:

| Category | Resources | Purpose |
|----------|-----------|---------|
| **Networking** | 7 | VPC, subnets, NAT, firewall rules |
| **GKE Cluster** | 2 | Kubernetes control plane + node pool |
| **Databases** | 15 | 3 Cloud SQL instances + 3 databases + 3 users + 6 passwords |
| **Service Networking** | 2 | Private IP for databases |
| **Backend Storage** | 1 | GCS bucket for Terraform state |
| **Data Sources** | 5 | Configuration lookups |

**Total Infrastructure Cost:** ~$250-300/month

---

## Network Infrastructure

### 1. **VPC Network** (`google_compute_network.vpc`)
```hcl
resource "google_compute_network" "vpc" {
  name                    = "digitalbank-vpc"
  auto_create_subnetworks = false
}
```

**Why it exists:**
- Custom isolated network for your banking platform
- Security: Prevents accidental cross-project communication
- Control: You define exactly which IP ranges to use
- **Without it:** Resources would use default VPC (shared, less secure)

**Integrates with:**
- ✅ GKE cluster (nodes run inside this VPC)
- ✅ Cloud SQL databases (private IPs in this VPC)
- ✅ Firewall rules (protect this network)

---

### 2. **Subnet** (`google_compute_subnetwork.subnet`)
```hcl
resource "google_compute_subnetwork" "subnet" {
  name          = "digitalbank-subnet"
  ip_cidr_range = "10.0.0.0/16"    # For nodes: 65,536 IPs
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"  # For pods: 65,536 IPs
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"  # For services: 65,536 IPs
  }
  
  private_ip_google_access = true
}
```

**Why it exists:**
- **Primary range (10.0.0.0/16):** Node IPs (your 9 nodes use 10.0.0.5-20)
- **Pods range (10.1.0.0/16):** Pod IPs (your 183 pods get 10.1.x.x)
- **Services range (10.2.0.0/16):** Service IPs (ClusterIP services)
- **private_ip_google_access:** Nodes can reach GCR, Cloud SQL without public IPs

**Integrates with:**
- ✅ GKE cluster (uses all 3 IP ranges)
- ✅ Cloud NAT (gives private nodes internet access)
- ✅ Firewall rules (control traffic between ranges)

**Real example from your cluster:**
```
Node:    gke-digitalbank-gke-n-17ab08f8-698s  → 10.0.0.12
Pod:     auth-api-5dfdf8556b-2czrq             → 10.1.3.14
Service: auth-api (ClusterIP)                  → 10.2.x.x
```

---

### 3. **Cloud Router** (`google_compute_router.router`)
```hcl
resource "google_compute_router" "router" {
  name    = "digitalbank-vpc-router"
  network = google_compute_network.vpc.id
}
```

**Why it exists:**
- Required for Cloud NAT
- Handles dynamic routing
- Manages network address translation

**Integrates with:**
- ✅ Cloud NAT (provides routing infrastructure)

---

### 4. **Cloud NAT** (`google_compute_router_nat.nat`)
```hcl
resource "google_compute_router_nat" "nat" {
  name   = "digitalbank-vpc-nat"
  router = google_compute_router.router.name
  
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

**Why it exists:**
- **Private nodes** (10.0.0.x) have NO public IPs
- Need to reach internet for: Docker images, apt packages, GitHub
- NAT translates private → public for outbound traffic

**Critical for:**
- ✅ Pulling images from GCR
- ✅ Installing packages in pods
- ✅ ArgoCD pulling from GitHub
- ✅ Jenkins pushing images

**Without it:** Your private nodes would be completely isolated, deployments would fail!

---

### 5. **Firewall Rules** (2 rules)

#### **Allow Internal Traffic**
```hcl
resource "google_compute_firewall" "allow_internal" {
  name = "digitalbank-vpc-allow-internal"
  
  allow { protocol = "tcp"; ports = ["0-65535"] }
  allow { protocol = "udp"; ports = ["0-65535"] }
  allow { protocol = "icmp" }
  
  source_ranges = [
    "10.0.0.0/16",  # Nodes
    "10.1.0.0/16",  # Pods
    "10.2.0.0/16"   # Services
  ]
}
```

**Why it exists:**
- Pods need to talk to each other (auth-api → accounts-api)
- Services need to reach pods
- Nodes need to communicate with control plane

**Allows:**
- ✅ frontend → auth-api (cross-pod communication)
- ✅ Prometheus → all pods (metrics scraping)
- ✅ Calico networking (pod-to-pod)

---

#### **Allow Health Checks**
```hcl
resource "google_compute_firewall" "allow_health_check" {
  name          = "digitalbank-vpc-allow-health-check"
  allow         { protocol = "tcp" }
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}
```

**Why it exists:**
- Google Load Balancer probes your services
- Ingress controller needs health checks
- LoadBalancer services need validation

**Critical for:**
- ✅ Ingress external IP assignment
- ✅ Service health monitoring
- ✅ Automatic failover

**Without it:** Your LoadBalancer services would never get external IPs!

---

### 6. **Private Service Connection** (`google_service_networking_connection`)
```hcl
resource "google_service_networking_connection" "private_vpc_connection" {
  network = google_compute_network.vpc.id
  service = "servicenetworking.googleapis.com"
  
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
```

**Why it exists:**
- Cloud SQL databases get **private IPs** (10.121.0.x)
- Pods connect to databases without leaving VPC
- More secure than public IPs

**Enables:**
- ✅ auth-api → 10.121.0.2 (private connection)
- ✅ No public database exposure
- ✅ Lower latency (same network)

---

## GKE Cluster

### 7. **GKE Cluster** (`google_container_cluster.primary`)
```hcl
resource "google_container_cluster" "primary" {
  name     = "digitalbank-gke"
  location = "us-central1"  # Regional = 3 zones
  
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  
  networking_mode = "VPC_NATIVE"
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
  
  addons_config {
    http_load_balancing { disabled = false }
    horizontal_pod_autoscaling { disabled = false }
    network_policy_config { disabled = false }
    gcp_filestore_csi_driver_config { enabled = true }
  }
}
```

**Why it exists:**
- **Kubernetes control plane** (managed by Google)
- Runs your 183 pods across 9 nodes
- Orchestrates containers, scaling, health checks

**Key configurations:**

#### **Regional Cluster (3 zones)**
- Spreads nodes across us-central1-a, -b, -c
- High availability: Zone failure won't kill cluster
- Your 9 nodes distributed 3-3-3

#### **VPC-Native Networking**
- Uses secondary IP ranges from subnet
- More efficient than routes-based
- Better performance

#### **Private Nodes**
- Nodes have NO public IPs (10.0.0.x only)
- More secure
- Requires Cloud NAT for internet

#### **Workload Identity**
- Pods can authenticate to GCP services
- No service account keys needed
- Used by: ArgoCD, Prometheus, system pods

#### **Calico Network Policy**
- Enforces pod-to-pod firewall rules
- Security between namespaces
- Enabled in your cluster

#### **Addons**
- **HTTP Load Balancing:** Ingress controller (your Ingress uses this)
- **Horizontal Pod Autoscaling:** Scale pods based on CPU/memory
- **Filestore CSI:** Persistent volumes support

**Integrates with:**
- ✅ VPC (network isolation)
- ✅ Subnet (IP allocation)
- ✅ Cloud NAT (internet access)
- ✅ Cloud SQL (database connections)
- ✅ GCR (image registry)

---

### 8. **Node Pool** (`google_container_node_pool.primary_nodes`)
```hcl
resource "google_container_node_pool" "primary_nodes" {
  name     = "digitalbank-gke-node-pool"
  cluster  = google_container_cluster.primary.name
  location = "us-central1"
  
  initial_node_count = 3
  
  autoscaling {
    min_node_count = 3
    max_node_count = 10
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  node_config {
    machine_type = "e2-standard-2"  # 2 vCPU, 8GB RAM
    disk_size_gb = 100
    disk_type    = "pd-balanced"
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
```

**Why it exists:**
- **Worker nodes** that run your pods
- Separate from control plane (managed by Google)
- Can scale independently

**Configuration explained:**

#### **Autoscaling (3-10 nodes)**
- Starts with 3 nodes (minimum)
- Scales up to 10 when pods pending
- Currently at 9 nodes (high load)
- Scales down automatically when idle

#### **Machine Type: e2-standard-2**
- 2 vCPU, 8GB RAM per node
- Good balance for banking workloads
- 9 nodes = 18 vCPU, 72GB RAM total

#### **Auto-repair & Auto-upgrade**
- Google fixes unhealthy nodes automatically
- Keeps Kubernetes version current
- No manual intervention needed

#### **Shielded Nodes**
- Secure boot prevents rootkit
- Integrity monitoring detects tampering
- Banking compliance requirement

**Your current state:**
- 9 nodes running
- ~20 pods per node
- ~60% resource utilization

---

## Database Layer

### 9-14. **Cloud SQL Instances** (3 databases)

Each microservice gets its own database for data isolation:

#### **Auth Database** (`google_sql_database_instance.auth_db`)
```hcl
resource "google_sql_database_instance" "auth_db" {
  name             = "digitalbank-auth-db"
  database_version = "POSTGRES_15"
  region           = "us-central1"
  
  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"  # Multi-zone HA
    disk_type         = "PD_SSD"
    disk_size         = 100
    disk_autoresize   = true
    
    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30  # 30 days of backups
      }
    }
    
    ip_configuration {
      ipv4_enabled    = false          # NO public IP
      private_network = google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }
}
```

**Why 3 separate databases:**
1. **Security:** Breach in one service doesn't expose all data
2. **Scalability:** Each DB can scale independently
3. **Microservices pattern:** Loose coupling
4. **Compliance:** Separation of concerns (auth vs transactions)

**Configuration explained:**

#### **REGIONAL Availability**
- Primary in one zone + standby in another
- Automatic failover if zone fails
- ~99.95% uptime SLA

#### **Backups**
- Daily automated backups at 2 AM
- Point-in-time recovery (restore to any second in last 7 days)
- 30 days retention
- Critical for banking compliance

#### **Private IP Only**
- Database at 10.121.0.2 (inside VPC)
- Pods connect via private network
- No internet exposure

#### **SSL Encryption**
- All connections encrypted
- Certificate validation
- Man-in-the-middle protection

**Your 3 databases:**

| Database | IP | Service | Purpose |
|----------|-----|---------|---------|
| digitalbank-auth-db | 10.121.0.2 | auth-api | Users, sessions, tokens |
| digitalbank-accounts-db | 10.121.0.3 | accounts-api | Account balances, transactions |
| digitalbank-transactions-db | 10.121.0.4 | transactions-api | Payment history, transfers |

---

### Database Users & Passwords

For each database, Terraform creates:

#### **Database** (`google_sql_database`)
```hcl
resource "google_sql_database" "auth_database" {
  name     = "authdb"
  instance = google_sql_database_instance.auth_db.name
}
```

#### **User** (`google_sql_user`)
```hcl
resource "google_sql_user" "auth_user" {
  name     = "authuser"
  instance = google_sql_database_instance.auth_db.name
  password = random_password.auth_db_password.result
}
```

#### **Random Password** (`random_password`)
```hcl
resource "random_password" "auth_db_password" {
  length  = 32
  special = true
}
```

**Why random passwords:**
- Generated by Terraform (not hardcoded)
- 32 characters with special chars
- Stored in Terraform state (encrypted in GCS)
- Injected into Kubernetes secrets

---

## Integration & Dependencies

### How Everything Connects:

```
1. VPC Network created first
   ↓
2. Subnet created (needs VPC)
   ↓
3. Cloud Router created (needs VPC)
   ↓
4. Cloud NAT created (needs Router)
   ↓
5. Firewall rules created (needs VPC)
   ↓
6. Service Networking Connection (needs VPC)
   ↓
7. Cloud SQL databases created (needs Service Connection)
   ↓
8. GKE Cluster created (needs VPC + Subnet)
   ↓
9. Node Pool created (needs GKE Cluster)
   ↓
10. Kubernetes provider configured (needs GKE endpoint)
    ↓
11. Helm provider configured (needs Kubernetes provider)
    ↓
12. Deploy applications (needs all of above)
```

---

## Resource Flow Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                        GCP PROJECT                             │
│                  charged-thought-485008-q7                     │
└────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
    ┌─────────▼─────────┐         ┌──────────▼──────────┐
    │   VPC Network     │         │   GCS Bucket        │
    │ digitalbank-vpc   │         │  (Terraform State)  │
    └─────────┬─────────┘         └─────────────────────┘
              │
    ┌─────────▼─────────────────────────────────────┐
    │              Subnet                           │
    │  Primary: 10.0.0.0/16 (Nodes)                │
    │  Pods:    10.1.0.0/16 (Pod IPs)              │
    │  Services:10.2.0.0/16 (ClusterIPs)           │
    └─────────┬─────────────────────────────────────┘
              │
    ┌─────────┴──────────┬──────────────┬──────────────┐
    │                    │              │              │
┌───▼────┐      ┌───────▼─────┐  ┌─────▼──────┐  ┌───▼────────┐
│ Cloud  │      │   Cloud     │  │  Firewall  │  │  Service   │
│ Router │─────▶│    NAT      │  │   Rules    │  │ Networking │
└────────┘      └─────────────┘  └────────────┘  └─────┬──────┘
                                                        │
                ┌───────────────────────────────────────┘
                │
    ┌───────────▼──────────────────────────────────┐
    │         GKE Cluster                          │
    │  - Control Plane: 172.16.0.0/28             │
    │  - Network: VPC-Native                       │
    │  - Workload Identity: Enabled                │
    │  - Calico Network Policy: Enabled            │
    └───────────┬──────────────────────────────────┘
                │
    ┌───────────▼──────────────────────────────────┐
    │         Node Pool                            │
    │  - Machine Type: e2-standard-2               │
    │  - Nodes: 9 (min 3, max 10)                 │
    │  - Private IPs: 10.0.0.x                    │
    │  - Shielded: Yes                             │
    └───────────┬──────────────────────────────────┘
                │
    ┌───────────▼──────────────────────────────────┐
    │         Pods (183 running)                   │
    │  - Application: 4 pods                       │
    │  - Monitoring: 14 pods                       │
    │  - ArgoCD: 7 pods                           │
    │  - System: 98+ pods                          │
    │  - IPs: 10.1.x.x                            │
    └──────────────────────────────────────────────┘

    ┌──────────────────────────────────────────────┐
    │      Cloud SQL (Private IPs)                 │
    │                                              │
    │  digitalbank-auth-db        10.121.0.2      │
    │  digitalbank-accounts-db    10.121.0.3      │
    │  digitalbank-transactions-db 10.121.0.4     │
    │                                              │
    │  Connected via Private Service Connection    │
    └──────────────────────────────────────────────┘
```

---

## Why Each Resource Exists

### **Critical Path (Must Have)**

| Resource | Why Absolutely Needed |
|----------|----------------------|
| **VPC** | Isolated network for security |
| **Subnet** | IP addresses for nodes, pods, services |
| **Cloud NAT** | Private nodes need internet (images, packages) |
| **GKE Cluster** | Run Kubernetes (orchestrate containers) |
| **Node Pool** | Worker machines to run pods |
| **Cloud SQL** | Persistent storage for banking data |
| **Service Networking** | Private database connections |

### **Security (Best Practice)**

| Resource | Security Benefit |
|----------|-----------------|
| **Private Cluster** | Nodes have no public IPs |
| **Firewall Rules** | Control traffic between resources |
| **SSL on Databases** | Encrypted data in transit |
| **Workload Identity** | Pods authenticate without keys |
| **Shielded Nodes** | Prevent rootkits, detect tampering |
| **Network Policies** | Isolate namespaces |

### **Reliability (Production-Grade)**

| Resource | Reliability Feature |
|----------|-------------------|
| **Regional HA (DBs)** | Automatic failover across zones |
| **Backups** | 30 days retention + PITR |
| **Autoscaling** | Handle traffic spikes (3-10 nodes) |
| **Auto-repair** | Replace unhealthy nodes automatically |
| **Multi-zone Cluster** | Survive zone outages |

### **Cost Optimization**

| Resource | Cost Saving |
|----------|-------------|
| **e2-standard-2** | Cheaper than n1-standard-2 (20% savings) |
| **Autoscaling** | Scale down when idle |
| **Shared VPC** | No per-resource networking fees |
| **Private IPs** | No egress charges to databases |
| **pd-balanced disks** | Cheaper than SSD, adequate performance |

---

## Terraform State Management

### **Remote Backend (GCS)**
```hcl
backend "gcs" {
  bucket = "charged-thought-485008-q7-tfstate"
  prefix = "digitalbank/terraform/state"
}
```

**Why remote state:**
- **Team collaboration:** Multiple people can run Terraform
- **State locking:** Prevents concurrent modifications
- **Backup:** State stored in GCS (versioned, durable)
- **Security:** Encrypted at rest

**Your state file contains:**
- All resource IDs (cluster name, database IPs, etc.)
- Sensitive data (database passwords)
- Resource dependencies
- Current infrastructure state

---

## Complete Resource List

### Created by Terraform (32 resources):

**Networking (7):**
1. VPC Network
2. Subnet
3. Cloud Router
4. Cloud NAT
5. Firewall: Allow Internal
6. Firewall: Allow Health Checks
7. Private Service Connection

**GKE (2):**
8. GKE Cluster
9. Node Pool

**Databases (15):**
10. Auth DB Instance
11. Auth Database
12. Auth User
13. Auth Password (random)
14. Auth Password (GCP secret)
15. Accounts DB Instance
16. Accounts Database
17. Accounts User
18. Accounts Password (random)
19. Accounts Password (GCP secret)
20. Transactions DB Instance
21. Transactions Database
22. Transactions User
23. Transactions Password (random)
24. Transactions Password (GCP secret)
25. Global Address (for Service Networking)

**Backend (1):**
26. GCS Bucket (Terraform state)

**Data Sources (5):**
27. Google Client Config
28. Compute Zones
29. Container Engine Versions
30. SQL Database Versions
31. Project Data

**Total Monthly Cost Breakdown:**
- GKE Nodes (9 × e2-standard-2): ~$150
- Cloud SQL (3 × db-f1-micro): ~$50
- Load Balancers (6 external IPs): ~$30
- NAT Gateway: ~$20
- Storage/Backups: ~$10
- **Total: ~$260/month**

---

## How to Modify Infrastructure

### **Scale Up Nodes:**
```bash
# Edit terraform/variables.tf
max_node_count = 15  # Change from 10

terraform plan
terraform apply
```

### **Upgrade Database:**
```bash
# Edit terraform/variables.tf
database_tier = "db-g1-small"  # Change from db-f1-micro

terraform plan
terraform apply
```

### **Add Firewall Rule:**
```bash
# Edit terraform/network.tf
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

terraform plan
terraform apply
```

---

## Destroy Infrastructure

**⚠️ WARNING: This deletes EVERYTHING (including databases!)**

```bash
cd terraform
terraform destroy
```

Will delete:
- All 9 GKE nodes
- All 183 pods
- All 3 databases (and data!)
- All network resources

**Protected resources:**
- Cloud SQL instances have `deletion_protection = true`
- Must manually disable before destroying

---

**Created:** January 29, 2026  
**Terraform Version:** 1.5+  
**GCP Provider:** 5.0+
