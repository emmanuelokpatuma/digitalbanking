# 🗺️ Terraform Structure & Network Architecture Explained

## 📁 Terraform File Organization

### Why We Split Into Multiple Files (Not Using Modules)

**Question:** "Do we use Terraform modules?"

**Answer:** **No, we use multiple `.tf` files in a single root module** (simpler approach)

```
terraform/
├── main.tf           # Provider configuration, backend setup
├── variables.tf      # All input variables
├── network.tf        # VPC, subnet, NAT, firewall rules
├── gke.tf           # GKE cluster and node pool
├── databases.tf     # Cloud SQL instances
├── outputs.tf       # Output values
└── terraform.tfvars # Variable values
```

**Why multiple files instead of modules?**
```
Modules (more complex):
terraform/
├── modules/
│   ├── network/     # Reusable network module
│   ├── gke/         # Reusable GKE module
│   └── database/    # Reusable database module
└── main.tf          # Calls modules

Single root module (our choice):
terraform/
├── network.tf       # All network resources
├── gke.tf          # All GKE resources
└── databases.tf    # All database resources

✅ Simpler for single environment
✅ Easier to understand for beginners
✅ No module version management
✅ Direct variable references
❌ Less reusable (but we only have 1 environment)
```

---

## 🌐 Network Architecture: Where Everything Lives

### The Complete Network Map

```
Google Cloud VPC: digitalbank-vpc
│
└── Subnet: digitalbank-subnet (10.0.0.0/24)
    │
    ├── PRIMARY IP RANGE: 10.0.0.0/24 (256 IPs)
    │   └── Used by: GKE NODES (VMs)
    │       ├── Node 1: 10.0.0.12
    │       ├── Node 2: 10.0.0.15
    │       └── Node 3: 10.0.0.18
    │
    ├── SECONDARY RANGE #1: "pods" → 10.1.0.0/16 (65,536 IPs)
    │   └── Used by: KUBERNETES PODS (Containers)
    │       ├── auth-api pod: 10.1.3.14
    │       ├── accounts-api pod: 10.1.8.22
    │       ├── transactions-api pod: 10.1.5.67
    │       ├── frontend pod: 10.1.7.45
    │       ├── prometheus pod: 10.1.5.23
    │       └── ~85 other pods: 10.1.x.x
    │
    └── SECONDARY RANGE #2: "services" → 10.2.0.0/16 (65,536 IPs)
        └── Used by: KUBERNETES SERVICES (ClusterIPs)
            ├── auth-api service: 10.2.171.160
            ├── accounts-api service: 10.2.xxx.xxx
            └── frontend service: 10.2.194.118

SEPARATE PEERED NETWORK (not in subnet):
└── Service Networking Range: 10.121.0.0/16
    └── Used by: CLOUD SQL DATABASES
        ├── auth-db: 10.121.0.2
        ├── accounts-db: 10.121.0.3
        └── transactions-db: 10.121.0.4
```

**CRITICAL UNDERSTANDING:**

1. **Containers (Pods) are in:** `10.1.0.0/16` (secondary range "pods")
2. **Databases are in:** `10.121.0.0/16` (VPC peered range)
3. **They're in the SAME VPC but DIFFERENT IP ranges**

---

## 📄 What Each Terraform File Contains

### 1. main.tf - The Foundation

**Purpose:** Provider configuration and state management

```hcl
# What it does:
├── Terraform version requirements (>= 1.5)
├── Provider versions (Google, Kubernetes, Helm)
├── Backend configuration (GCS bucket for state)
└── Provider authentication setup
```

**Created resources:** ZERO (just configuration)

**Why it exists:**
```
Think of main.tf as the "settings file"
- Where to store Terraform state? → GCS bucket
- Which GCP project to use? → charged-thought-485008-q7
- How to authenticate to Kubernetes? → Use GKE cluster credentials
```

**Key code:**
```hcl
backend "gcs" {
  bucket = "charged-thought-485008-q7-tfstate"  # Where state is saved
  prefix = "digitalbank/terraform/state"
}

provider "google" {
  project = var.project_id  # All resources go in this project
  region  = var.region      # Default region: us-central1
}
```

---

### 2. network.tf - The Network Layer

**Purpose:** Creates the VPC, subnet, NAT, and firewall rules

**Created resources:** 7 resources

```hcl
1. google_compute_network.vpc
   └── Name: digitalbank-vpc
   └── Purpose: Isolated network for entire platform

2. google_compute_subnetwork.subnet
   └── Name: digitalbank-subnet
   └── Primary: 10.0.0.0/24 (for GKE nodes)
   └── Secondary "pods": 10.1.0.0/16 (for containers)
   └── Secondary "services": 10.2.0.0/16 (for services)

3. google_compute_router.router
   └── Name: digitalbank-vpc-router
   └── Purpose: Required for Cloud NAT

4. google_compute_router_nat.nat
   └── Name: digitalbank-vpc-nat
   └── Purpose: Allows private nodes to access internet

5. google_compute_firewall.allow_internal
   └── Allows: All traffic between nodes, pods, services
   └── Source: 10.0.0.0/24, 10.1.0.0/16, 10.2.0.0/16

6. google_compute_firewall.allow_health_check
   └── Allows: Google health checks to reach pods
   └── Source: 35.191.0.0/16, 130.211.0.0/22

7. google_service_networking_connection.private_vpc_connection
   └── Purpose: Connects VPC to Cloud SQL (VPC peering)
   └── Reserves: 10.121.0.0/16 for databases
```

**Why secondary ranges?**
```hcl
secondary_ip_range {
  range_name    = "pods"
  ip_cidr_range = "10.1.0.0/16"
}
```

**Explanation:**
```
WITHOUT secondary ranges:
Node 1 (10.0.0.12) runs 30 pods
  → Need 30 IPs but node only has 1 IP ❌
  → Would need separate subnet per pod (nightmare!)

WITH secondary ranges (alias IPs):
Node 1 (10.0.0.12)
  ├── Primary IP: 10.0.0.12 (for node itself)
  └── Alias IPs from 10.1.0.0/16:
      ├── Pod 1: 10.1.3.14
      ├── Pod 2: 10.1.3.15
      └── Pod 30: 10.1.3.44

Result: All on same subnet, efficient routing! ✅
```

**Where firewall rules live:** In `network.tf`

**Why?** Firewalls protect the VPC, so they're logically grouped with VPC/subnet

---

### 3. gke.tf - The Kubernetes Cluster

**Purpose:** Creates GKE cluster and node pool

**Created resources:** 2 resources

```hcl
1. google_container_cluster.primary
   └── Name: digitalbank-gke
   └── Location: us-central1 (regional, 3 zones)
   └── Network: digitalbank-vpc ←─┐
   └── Subnetwork: digitalbank-subnet ←─┘ CONNECTS to network.tf
   └── Uses secondary ranges: "pods" and "services"

2. google_container_node_pool.primary_nodes
   └── Name: digitalbank-gke-node-pool
   └── Machine type: e2-standard-2 (2 vCPU, 8GB RAM)
   └── Node count: 1 per zone (3 total)
   └── Runs in: digitalbank-subnet (gets 10.0.0.x IPs)
```

**How GKE connects to the network:**
```hcl
# In gke.tf
resource "google_container_cluster" "primary" {
  network    = google_compute_network.vpc.name          # ← References network.tf
  subnetwork = google_compute_subnetwork.subnet.name    # ← References network.tf
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"      # ← Uses secondary range from network.tf
    services_secondary_range_name = "services"  # ← Uses secondary range from network.tf
  }
}
```

**What this means:**
```
1. Nodes are created in: digitalbank-subnet (10.0.0.0/24)
   → Node 1 gets IP: 10.0.0.12
   
2. When Kubernetes creates a pod:
   → Kubernetes asks: "Give me an IP from the 'pods' range"
   → Google allocates: 10.1.3.14 (from 10.1.0.0/16)
   → Pod IP is an "alias IP" on the node
   
3. When Kubernetes creates a service:
   → Kubernetes asks: "Give me an IP from the 'services' range"
   → Google allocates: 10.2.171.160 (from 10.2.0.0/16)
   → Service IP is virtual (iptables routing)
```

**Where GKE resources live:** In `gke.tf`

**Why?** All Kubernetes-related configuration in one place

---

### 4. databases.tf - The Database Layer

**Purpose:** Creates Cloud SQL instances with private IPs

**Created resources:** 15 resources (3 instances + 3 databases + 3 users + 6 passwords)

```hcl
1-3. Database Instances:
   ├── google_sql_database_instance.auth_db
   ├── google_sql_database_instance.accounts_db
   └── google_sql_database_instance.transactions_db
   
   Each instance:
   ├── Version: PostgreSQL 15
   ├── Tier: db-n1-standard-1 (1 vCPU, 3.75GB RAM)
   ├── Private IP: 10.121.0.x (from VPC peering)
   └── Public IP: 34.x.x.x (for DBeaver access)

4-6. Databases:
   ├── google_sql_database.auth_database (authdb)
   ├── google_sql_database.accounts_database (accountsdb)
   └── google_sql_database.transactions_database (transactionsdb)

7-9. Users:
   ├── google_sql_user.auth_user (authuser)
   ├── google_sql_user.accounts_user (accountsuser)
   └── google_sql_user.transactions_user (transactionsuser)

10-15. Random Passwords:
   └── 6 random_password resources (auto-generated)
```

**How databases connect to the network:**
```hcl
# In databases.tf
resource "google_sql_database_instance" "auth_db" {
  settings {
    ip_configuration {
      ipv4_enabled    = false                              # No public IP initially
      private_network = google_compute_network.vpc.id      # ← CONNECTS to network.tf
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }
  
  depends_on = [google_service_networking_connection.private_vpc_connection]
                # ↑ Waits for VPC peering from network.tf
}
```

**Where databases get their IPs:**
```
1. Network.tf reserves IP range:
   google_service_networking_connection → reserves 10.121.0.0/16

2. Database.tf creates instances:
   ├── Instance 1 → Google assigns: 10.121.0.2
   ├── Instance 2 → Google assigns: 10.121.0.3
   └── Instance 3 → Google assigns: 10.121.0.4

3. Result: Databases in 10.121.0.0/16, accessible from pods in 10.1.0.0/16
   (both in same VPC via peering)
```

**Where database resources live:** In `databases.tf`

**Why?** All database configuration in one place

---

## 🔗 How Everything Connects

### Connection Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ TERRAFORM FILES & RESOURCE DEPENDENCIES                         │
└─────────────────────────────────────────────────────────────────┘

main.tf (Configuration only)
  └── Sets up providers & backend

network.tf (7 resources)
  ├── google_compute_network.vpc
  │   └── Creates: digitalbank-vpc
  │
  ├── google_compute_subnetwork.subnet
  │   ├── Requires: vpc (above)
  │   └── Creates: 10.0.0.0/24, 10.1.0.0/16, 10.2.0.0/16
  │
  ├── google_compute_router.router
  │   ├── Requires: vpc
  │   └── Enables: Cloud NAT
  │
  ├── google_compute_router_nat.nat
  │   ├── Requires: router
  │   └── Provides: Internet access for private nodes
  │
  ├── google_compute_firewall.* (2 rules)
  │   ├── Requires: vpc
  │   └── Protects: All resources in VPC
  │
  └── google_service_networking_connection
      ├── Requires: vpc
      └── Reserves: 10.121.0.0/16 for Cloud SQL

gke.tf (2 resources)
  ├── google_container_cluster.primary
  │   ├── Requires: vpc, subnet ←──────┐
  │   ├── Uses: "pods" secondary range │  DEPENDENCY
  │   └── Uses: "services" secondary   │   FROM
  │                                     │  network.tf
  └── google_container_node_pool       │
      ├── Requires: cluster (above)    │
      └── Places nodes in: subnet ─────┘

databases.tf (15 resources)
  ├── google_sql_database_instance.* (3 instances)
  │   ├── Requires: vpc ←──────────────┐
  │   ├── Requires: service_networking_connection  DEPENDENCY
  │   └── Gets IPs from: 10.121.0.0/16 │   FROM
  │                                     │  network.tf
  ├── google_sql_database.* (3 databases)
  │   └── Requires: instances (above)
  │
  └── google_sql_user.* (3 users)
      └── Requires: instances (above)
```

### Terraform Apply Order (Automatic Dependency Resolution)

```bash
terraform apply

Step 1: Create network.tf resources
  ├── VPC created first
  ├── Subnet created (depends on VPC)
  ├── Router created (depends on VPC)
  ├── NAT created (depends on Router)
  ├── Firewalls created (depends on VPC)
  └── Service networking connection (depends on VPC)

Step 2: Create gke.tf resources (parallel with databases)
  ├── Cluster created (depends on VPC + subnet)
  └── Node pool created (depends on cluster)

Step 3: Create databases.tf resources (parallel with GKE)
  ├── Instances created (depends on VPC + service connection)
  ├── Databases created (depends on instances)
  └── Users created (depends on instances)

Total time: ~15-20 minutes
```

**Why this order?**
```
Terraform analyzes all resource blocks and builds a dependency graph:

VPC (no dependencies)
  ↓
Subnet (needs VPC)
  ↓
GKE Cluster (needs VPC + Subnet)
  ↓
Node Pool (needs Cluster)

This happens automatically! You don't specify order.
```

---

## 🎯 Answering Your Questions

### Q1: "In which subnet do we have our containers?"

**Answer:** Containers (pods) use the **secondary IP range "pods"** in `digitalbank-subnet`

```
Subnet: digitalbank-subnet
├── Primary range: 10.0.0.0/24 → For GKE nodes (VMs)
├── Secondary "pods": 10.1.0.0/16 → For CONTAINERS ✅
└── Secondary "services": 10.2.0.0/16 → For Kubernetes services
```

**Technical detail:**
- Containers don't get IPs from a separate subnet
- They get "alias IPs" from the pods secondary range
- All containers: 10.1.x.x

### Q2: "Where do we have databases?"

**Answer:** Databases use a **VPC-peered IP range:** `10.121.0.0/16`

```
This is NOT in the subnet!
It's a separate range connected via VPC peering.

Created by: google_service_networking_connection (in network.tf)
Used by: Cloud SQL instances (in databases.tf)

Databases:
├── auth-db: 10.121.0.2
├── accounts-db: 10.121.0.3
└── transactions-db: 10.121.0.4
```

### Q3: "Where did we add the firewall?"

**Answer:** Firewall rules are in **network.tf**

```hcl
# In network.tf
resource "google_compute_firewall" "allow_internal" {
  name    = "digitalbank-vpc-allow-internal"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  source_ranges = [
    "10.0.0.0/24",   # Nodes can talk to each other
    "10.1.0.0/16",   # Pods can talk to each other
    "10.2.0.0/16"    # Services accessible from pods
  ]
}
```

**Why in network.tf?**
- Firewalls protect the VPC
- Logically grouped with network resources
- Depends on VPC being created first

### Q4: "Where is GKE defined?"

**Answer:** GKE cluster and node pool are in **gke.tf**

```hcl
# In gke.tf
resource "google_container_cluster" "primary" {
  name     = "digitalbank-gke"
  network  = google_compute_network.vpc.name      # From network.tf
  subnetwork = google_compute_subnetwork.subnet.name  # From network.tf
}

resource "google_container_node_pool" "primary_nodes" {
  cluster = google_container_cluster.primary.name
  node_count = 1  # Per zone
}
```

### Q5: "Were modules used?"

**Answer:** **NO, we used multiple .tf files (simpler approach)**

```
Modules approach (not used):
terraform/
├── modules/
│   ├── network/
│   ├── gke/
│   └── database/
└── main.tf (calls modules)

Our approach (flat structure):
terraform/
├── main.tf (config)
├── network.tf (all network resources)
├── gke.tf (all GKE resources)
└── databases.tf (all database resources)

Benefit: Simpler, easier to understand
Drawback: Less reusable (but we only have 1 environment)
```

### Q6: "How are all connected?"

**Answer:** Through Terraform references and GCP networking

**Terraform connections (code references):**
```hcl
# gke.tf references network.tf
network    = google_compute_network.vpc.name
subnetwork = google_compute_subnetwork.subnet.name

# databases.tf references network.tf
private_network = google_compute_network.vpc.id
depends_on = [google_service_networking_connection.private_vpc_connection]
```

**GCP networking connections:**
```
1. GKE nodes → Created in subnet (10.0.0.0/24)
2. Pods → Get IPs from pods range (10.1.0.0/16)
3. Services → Get IPs from services range (10.2.0.0/16)
4. Databases → Get IPs from peered range (10.121.0.0/16)

All in same VPC = can communicate!

Pod (10.1.3.14) → Database (10.121.0.2) ✅
  Route: Direct through VPC (no internet)
```

---

## 📊 Visual Summary

```
TERRAFORM FILE → CREATES → NETWORK RANGE → USED BY
─────────────────────────────────────────────────────
network.tf    → VPC        → N/A            → Everything
network.tf    → Subnet     → 10.0.0.0/24    → GKE Nodes
network.tf    → Subnet     → 10.1.0.0/16    → Containers (Pods)
network.tf    → Subnet     → 10.2.0.0/16    → Services
network.tf    → VPC Peering→ 10.121.0.0/16  → Databases
network.tf    → Firewall   → N/A            → Protects all
network.tf    → Cloud NAT  → N/A            → Outbound internet
gke.tf        → GKE        → Uses above     → Runs containers
databases.tf  → Cloud SQL  → Uses peering   → Stores data
main.tf       → Providers  → N/A            → Configuration
```

---

**Last Updated:** January 29, 2026
