# Cloud SQL for PostgreSQL - Auth Database
resource "google_sql_database_instance" "auth_db" {
  name             = "digitalbank-auth-db"
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.database_tier
    availability_type = "REGIONAL"
    disk_type         = "PD_SSD"
    disk_size         = 100
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    database_flags {
      name  = "max_connections"
      value = "200"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
    }
  }

  deletion_protection = true

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "auth_database" {
  name     = "authdb"
  instance = google_sql_database_instance.auth_db.name
  project  = var.project_id
}

resource "google_sql_user" "auth_user" {
  name     = "authuser"
  instance = google_sql_database_instance.auth_db.name
  password = random_password.auth_db_password.result
  project  = var.project_id
}

# Cloud SQL for PostgreSQL - Accounts Database
resource "google_sql_database_instance" "accounts_db" {
  name             = "digitalbank-accounts-db"
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.database_tier
    availability_type = "REGIONAL"
    disk_type         = "PD_SSD"
    disk_size         = 100
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      start_time                     = "02:30"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    database_flags {
      name  = "max_connections"
      value = "200"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
    }
  }

  deletion_protection = true

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "accounts_database" {
  name     = "accountsdb"
  instance = google_sql_database_instance.accounts_db.name
  project  = var.project_id
}

resource "google_sql_user" "accounts_user" {
  name     = "accountsuser"
  instance = google_sql_database_instance.accounts_db.name
  password = random_password.accounts_db_password.result
  project  = var.project_id
}

# Cloud SQL for PostgreSQL - Transactions Database
resource "google_sql_database_instance" "transactions_db" {
  name             = "digitalbank-transactions-db"
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.database_tier
    availability_type = "REGIONAL"
    disk_type         = "PD_SSD"
    disk_size         = 100
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    database_flags {
      name  = "max_connections"
      value = "200"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
    }
  }

  deletion_protection = true

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "transactions_database" {
  name     = "transactionsdb"
  instance = google_sql_database_instance.transactions_db.name
  project  = var.project_id
}

resource "google_sql_user" "transactions_user" {
  name     = "transactionsuser"
  instance = google_sql_database_instance.transactions_db.name
  password = random_password.transactions_db_password.result
  project  = var.project_id
}

# Private VPC Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Random passwords for databases
resource "random_password" "auth_db_password" {
  length  = 32
  special = true
}

resource "random_password" "accounts_db_password" {
  length  = 32
  special = true
}

resource "random_password" "transactions_db_password" {
  length  = 32
  special = true
}

# Store passwords in Secret Manager
resource "google_secret_manager_secret" "auth_db_password" {
  secret_id = "auth-db-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "auth_db_password" {
  secret      = google_secret_manager_secret.auth_db_password.id
  secret_data = random_password.auth_db_password.result
}

resource "google_secret_manager_secret" "accounts_db_password" {
  secret_id = "accounts-db-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "accounts_db_password" {
  secret      = google_secret_manager_secret.accounts_db_password.id
  secret_data = random_password.accounts_db_password.result
}

resource "google_secret_manager_secret" "transactions_db_password" {
  secret_id = "transactions-db-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "transactions_db_password" {
  secret      = google_secret_manager_secret.transactions_db_password.id
  secret_data = random_password.transactions_db_password.result
}
