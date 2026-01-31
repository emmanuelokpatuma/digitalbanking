┌───────────────────────────────────────────────────────────────────────────────┐
│                         GOOGLE CLOUD PLATFORM                                  │
│                  Project: charged-thought-485008-q7                            │
│                         Region: us-central1                                    │
└───────────────────────────────────────────────────────────────────────────────┘
                                   │
                             Internet
                                   │
                      ┌────────────▼────────────┐
                      │ External HTTP(S) LB      │
                      │ (Ingress / Services)     │
                      └────────────┬────────────┘
                                   │
┌───────────────────────────────────▼───────────────────────────────────────────┐
│                           VPC: digitalbank-vpc                                 │
│                           Primary: 10.0.0.0/24                                 │
│                                                                                 │
│  ┌───────────────────────────────┐     ┌───────────────────────────────────┐  │
│  │ Firewall Rules                │     │ Cloud Router + NAT                │  │
│  │ • allow-internal              │     │ • Outbound internet only          │  │
│  │ • allow-health-check          │     │ • No inbound access               │  │
│  └───────────────┬───────────────┘     └───────────────┬───────────────────┘  │
│                  │                                     │                      │
│  ┌───────────────▼─────────────────────────────────────▼───────────────────┐ │
│  │                         GKE Cluster (Private)                             │ │
│  │                    digitalbank-gke (Regional)                            │ │
│  │                                                                           │ │
│  │  Pods CIDR:     10.1.0.0/16                                               │ │
│  │  Services CIDR: 10.2.0.0/16                                               │ │
│  │                                                                           │ │
│  │  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                │ │
│  │  │ us-central1-a│   │ us-central1-b│   │ us-central1-f│                │ │
│  │  │ 3 GKE Nodes  │   │ 3 GKE Nodes  │   │ 3 GKE Nodes  │                │ │
│  │  └──────────────┘   └──────────────┘   └──────────────┘                │ │
│  └──────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌───────────────────────────── VPC PEERING ───────────────────────────────┐ │
│  │                                                                           │ │
│  │   ┌──────────────┐  ┌────────────────┐  ┌────────────────────────┐      │ │
│  │   │ Auth DB      │  │ Accounts DB    │  │ Transactions DB         │      │ │
│  │   │ PostgreSQL   │  │ PostgreSQL     │  │ PostgreSQL              │      │ │
│  │   │ Private IP   │  │ Private IP     │  │ Private IP              │      │ │
│  │   └──────────────┘  └────────────────┘  └────────────────────────┘      │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘

---

## Terraform Resource Inventory & Count

| Resource Type                              | Count | Description                                    |
|--------------------------------------------|-------|------------------------------------------------|
| google_compute_network                     |   1   | VPC network                                    |
| google_compute_subnetwork                  |   1   | Subnet with secondary ranges                   |
| google_compute_router                      |   1   | Cloud Router                                   |
| google_compute_router_nat                  |   1   | Cloud NAT                                      |
| google_compute_firewall                    |   2   | VPC-wide firewall rules                        |
| google_container_cluster                   |   1   | GKE cluster                                    |
| google_container_node_pool                 |   1   | GKE node pool                                  |
| google_sql_database_instance               |   3   | Cloud SQL instances (auth, accounts, tx)       |
| google_sql_database                        |   3   | Databases inside each Cloud SQL instance       |
| google_sql_user                            |   3   | DB users for each Cloud SQL instance           |
| google_compute_global_address              |   1   | Private IP for VPC peering                     |
| google_service_networking_connection       |   1   | VPC peering connection for Cloud SQL           |
| random_password                           |   3   | Random DB passwords                            |
| google_secret_manager_secret               |   3   | Secret Manager secrets for DB passwords        |
| google_secret_manager_secret_version       |   3   | Secret Manager secret versions                 |
|                                            |       |                                                |
| **Total Terraform Resources**              | **29**|                                                |

---

### Why 3 Secret Manager Resources?
- **google_secret_manager_secret** and **google_secret_manager_secret_version** are created for each database password:
  - 1 for auth-db password
  - 1 for accounts-db password
  - 1 for transactions-db password
- This ensures each Cloud SQL instance has its own unique, securely stored password in Secret Manager.

### Why 2 VPC Firewall Rules?
- **allow-internal**: Permits all internal traffic between nodes, pods, and services within the VPC (using all relevant CIDR ranges).
- **allow-health-check**: Allows Google Cloud Load Balancer health checks to reach GKE nodes (using GCP LB IP ranges and target tags).
- Both are required for secure, functional cluster networking and external access.

**Total Terraform resources created:**

> **29 resources**

This includes all networking, security, GKE, database, password, and secret management resources required for a production-grade digital banking platform on GCP.
