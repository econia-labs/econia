terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "google_sql_database_instance" "postgres" {
  database_version    = "POSTGRES_14"
  deletion_protection = false
  root_password       = var.db_root_password
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
    }
  }
}

resource "google_sql_database" "database" {
  name     = "econia"
  instance = google_sql_database_instance.postgres.name
}

resource "google_compute_firewall" "pg-admin" {
  name          = "pg-admin"
  network       = "default"
  source_ranges = [var.db_admin_public_ip]
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
}