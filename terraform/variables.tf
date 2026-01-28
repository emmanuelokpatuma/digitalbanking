variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "GKE Cluster name"
  type        = string
  default     = "digitalbank-gke"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "digitalbank-vpc"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "digitalbank-subnet"
}

variable "subnet_cidr" {
  description = "Subnet CIDR range"
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  description = "Pods secondary CIDR range"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "Services secondary CIDR range"
  type        = string
  default     = "10.2.0.0/16"
}

variable "master_ipv4_cidr_block" {
  description = "Master IPv4 CIDR block"
  type        = string
  default     = "172.16.0.0/28"
}

variable "node_count" {
  description = "Number of nodes per zone"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "Minimum number of nodes"
  type        = number
  default     = 3
}

variable "max_node_count" {
  description = "Maximum number of nodes"
  type        = number
  default     = 10
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "digitalbank.example.com"
}

variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging stack"
  type        = bool
  default     = true
}

variable "database_tier" {
  description = "Cloud SQL tier"
  type        = string
  default     = "db-custom-2-7680"
}

variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"
}

variable "pods_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
  default     = "pods-range"
}

variable "services_range_name" {
  description = "Name of the secondary range for services"
  type        = string
  default     = "services-range"
}

variable "db_tier" {
  description = "Database instance tier (alias for database_tier)"
  type        = string
  default     = "db-custom-2-7680"
}

variable "db_version" {
  description = "Database version (alias for database_version)"
  type        = string
  default     = "POSTGRES_15"
}
