# Digital Banking Platform - Network Architecture Explained

**Date**: January 31, 2026

---

## 1️⃣ The Single, Correct Diagram

```
🌍 INTERNET
    │
    │ (HTTPS)
    ▼
┌─────────────────────────────┐
│  External Load Balancer    │
│  (GKE-managed, TLS, health │
│   checks, no direct pod    │
│   exposure)                │
└─────────────────────────────┘
    │
    │ (VPC ingress)
    ▼
┌────────────────────────────────────────────────────────────┐
│                   YOUR VPC NETWORK                        │
│                                                          │
│  ┌───────────────┐    ┌──────────────────────────────┐    │
│  │ VPC Firewalls │──▶ │ GKE Nodes (private IPs only) │    │
│  │ (VPC-wide)    │    │  • Node Pool                 │    │
│  └───────────────┘    │  • No public IPs             │    │
│           │           └───────────────┬──────────────┘    │
│           │                           │                  │
│           │                           ▼                  │
│           │                  ┌────────────────┐          │
│           │                  │ Kubernetes Pods │          │
│           │                  │ (Auth, Acct,   │          │
│           │                  │  Tx services)  │          │
│           │                  └────────────────┘          │
│           │                           │                  │
│           │                           │ (Service DNS)    │
│           │                           ▼                  │
│           │                  ┌────────────────┐          │
│           │                  │ K8s Services   │          │
│           │                  │ (virtual IPs)  │          │
│           │                  └────────────────┘          │
│           │                                              │
│           │  ┌──────────────────────────────┐            │
│           │  │ Cloud Router (region brain)  │            │
│           │  └───────────────┬──────────────┘            │
│           │                  │                          │
│           │                  ▼                          │
│           │  ┌──────────────────────────────┐            │
│           │  │ Cloud NAT (egress only)      │            │
│           │  │ • No inbound allowed         │            │
│           │  └───────────────┬──────────────┘            │
│           │                  │                          │
└───────────┼──────────────────┼──────────────────────────┘
            │                  │
            │                  ▼
            │              🌍 INTERNET
            │
            │ (private IP only)
            ▼
┌────────────────────────────────────────────────────────────┐
│   GOOGLE-MANAGED SERVICE NETWORK (NOT YOUR VPC)           │
│                                                          │
│  ┌───────────────────────────────────────────────────┐    │
│  │ Cloud SQL (PostgreSQL)                            │    │
│  │  • auth_db                                        │    │
│  │  • accounts_db                                    │    │
│  │  • transactions_db                                │    │
│  │  • Private IP                                     │    │
│  └───────────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────┘
```

---

## 2️⃣ What Each Layer Does (Human Explanation)

### 🌍 Internet
- Users, external APIs, container registries
- Nothing inside your VPC is directly exposed

### ⚖️ External Load Balancer (GKE-managed)
- Single, secure entry point
- TLS termination, health checks
- No public IPs on nodes, no direct pod exposure

### 🔥 VPC Firewall (NOT subnet-level)
- Global traffic policy
- Allow only what you explicitly want
- Applies to entire VPC
- Filtered by source CIDR, target tags (gke-node), direction
- Your rules: allow internal pod↔node traffic, allow Google health checks

### 🖥 GKE Nodes (Compute boundary)
- Pods must run on something
- Nodes are the only thing that touches the VPC
- Security: private IPs only, Shielded VMs, custom service account
- Pods never touch the VPC directly

### 📦 Pods (Application runtime)
- Your banking logic
- Stateless compute
- Pod IPs are from secondary ranges, routable inside VPC, not internet-reachable

### 📬 Kubernetes Services
- Stable DNS + IP
- Load balancing between pods
- Not a real network hop, purely logical

### 🧠 Cloud Router
- Regional routing brain
- Required for Cloud NAT
- Decides: is this destination inside VPC? Is this internet-bound?
- No packets flow through it

### 🚪 Cloud NAT
- Outbound internet access
- No inbound allowed
- No public IPs on nodes
- Critical security point: NAT allows out, not in

### 🔐 Private VPC Peering (Service Networking)
- Secure, private connectivity
- No internet, no NAT
- Pod → Cloud SQL works safely

### 🗄 Cloud SQL (Google-managed network)
- Managed HA database
- Backups, PITR, patching handled by Google
- NOT in your subnet, NOT in your VPC
- Still reachable via private IP
- This is expected and correct

---

## 3️⃣ Mapping Directly to Your Terraform (Why Each Exists)

### Networking
- `google_compute_network` → security + routing boundary
- `google_compute_subnetwork` → IP space only
- Secondary ranges → Pods + Services

### Security
- `google_compute_firewall` → VPC-wide policy
- Tags → target nodes only

### GKE
- Private cluster → no public nodes
- Workload Identity → no node credentials leakage
- Node SA → least privilege

### Databases
- `google_sql_database_instance` → managed DB
- `private_network` → private IP only
- `google_service_networking_connection` → peering
- No public DB exposure needed

### Egress
- `google_compute_router` → routing control
- `google_compute_router_nat` → outbound-only internet

---

**This is the recommended, production-grade GCP architecture for banking and fintech.**
