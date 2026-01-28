# Project Configuration
project_id   = "charged-thought-485008-q7"
region       = "us-central1"
zone         = "us-central1-a"
environment  = "production"

# GKE Configuration
cluster_name     = "digitalbank-gke"
node_count       = 3
min_node_count   = 3
max_node_count   = 10
machine_type     = "e2-standard-2"

# Database Configuration
db_tier          = "db-custom-2-7680"
db_version       = "POSTGRES_15"

# Network Configuration
network_name     = "digitalbank-vpc"
subnet_name      = "digitalbank-subnet"
pods_range_name  = "pods-range"
services_range_name = "services-range"
