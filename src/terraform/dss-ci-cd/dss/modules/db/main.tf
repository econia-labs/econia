terraform {
  required_providers {
    # https://github.com/hashicorp/terraform-provider-google/issues/16275#issuecomment-1825752152
    google-beta-sql-network-workaround = {
      source  = "hashicorp/google-beta"
      version = "~>4"
    }
  }
}

locals {
  db_connection_name = google_sql_database_instance.postgres.connection_name
  db_conn_str_auth_proxy = replace(
    local.db_conn_str_base,
    "IP_ADDRESS",
    "127.0.0.1"
  )
  db_conn_str_base = join("", [
    "postgres://postgres:",
    var.db_root_password,
    "@IP_ADDRESS:5432/econia"
  ])
  db_conn_str_private = replace(
    local.db_conn_str_base,
    "IP_ADDRESS",
    "${google_sql_database_instance.postgres.private_ip_address}"
  )
}

resource "google_sql_database_instance" "postgres" {
  database_version    = "POSTGRES_14"
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.sql_network_connection,
  ]
  root_password = var.db_root_password
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
  provider                = google-beta-sql-network-workaround
  reserved_peering_ranges = [google_compute_global_address.postgres_private_ip_address.name]
  service                 = "servicenetworking.googleapis.com"
}

# Run Cloud SQL Auth Proxy in background, run migrations, kill proxy.
resource "terraform_data" "run_migrations" {
  depends_on = [google_sql_database.database]
  provisioner "local-exec" {
    command = join("\n", [
      join(" ", [
        "cloud-sql-proxy",
        local.db_connection_name,
        "--credentials-file",
        var.credentials_file,
        "&"
      ]),
      "sleep 5", # Give proxy time to start up.
      "diesel migration run --migration-dir migrations",
      "psql $DATABASE_URL -c 'GRANT web_anon to postgres'",
      # https://unix.stackexchange.com/a/104825
      "kill $(pgrep cloud-sql-proxy)",
    ])
    environment = {
      DATABASE_URL = local.db_conn_str_auth_proxy,
    }
  }
}
