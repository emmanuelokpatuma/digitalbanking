output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.subnet.name
}

output "auth_db_connection_name" {
  description = "Auth database connection name"
  value       = google_sql_database_instance.auth_db.connection_name
}

output "accounts_db_connection_name" {
  description = "Accounts database connection name"
  value       = google_sql_database_instance.accounts_db.connection_name
}

output "transactions_db_connection_name" {
  description = "Transactions database connection name"
  value       = google_sql_database_instance.transactions_db.connection_name
}

output "configure_kubectl" {
  description = "Configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}
