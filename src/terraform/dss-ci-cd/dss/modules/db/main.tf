# https://github.com/hashicorp/terraform-provider-google/issues/16275#issuecomment-1825752152
provider "google-beta" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

resource "google_sql_database_instance" "postgres" {
  database_version    = "POSTGRES_14"
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.sql_network_connection,
  ]
  settings {
    insights_config {
      query_insights_enabled = true
      query_plans_per_minute = 20
      query_string_length    = 4500
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.sql_network.id
    }
    tier = "db-custom-4-16384"
  }
}

resource "google_sql_database" "database" {
  deletion_policy = "ABANDON"
  instance        = google_sql_database_instance.postgres.name
  name            = "econia"
}

resource "google_compute_global_address" "postgres_private_ip_address" {
  address_type  = "INTERNAL"
  name          = "postgres-private-ip-address"
  network       = google_compute_network.sql_network.id
  prefix_length = 16
  purpose       = "VPC_PEERING"
}

resource "google_compute_network" "sql_network" {
  name = "sql-network"
}

resource "google_service_networking_connection" "sql_network_connection" {
  network                 = google_compute_network.sql_network.id
  provider                = google-beta
  reserved_peering_ranges = [google_compute_global_address.postgres_private_ip_address.name]
  service                 = "servicenetworking.googleapis.com"
}
