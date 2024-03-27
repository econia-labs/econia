# Enabling Private IP:
# https://stackoverflow.com/questions/54278828
# Destroying VPC peering:
# https://github.com/hashicorp/terraform-provider-google/issues/16275#issuecomment-1825752152
terraform {
  required_providers {
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
  db_conn_str_private_grafana = join("", [
    trimsuffix(local.db_conn_str_private, "econia"),
    "grafana"
  ])
  db_private_ip_and_port = join("", [
    google_sql_database_instance.postgres.private_ip_address,
    ":5432"
  ])
}

resource "google_sql_database_instance" "postgres" {
  database_version    = "POSTGRES_14"
  deletion_protection = false
  depends_on          = [google_service_networking_connection.sql_network_connection]
  provider            = google-beta
  root_password       = var.db_root_password
  settings {
    # Prevents large backfill operations from erroring out.
    database_flags {
      name  = "temp_file_limit"
      value = "2147483647"
    }
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

resource "google_sql_database" "grafana_state" {
  deletion_policy = "ABANDON"
  instance        = google_sql_database_instance.postgres.name
  name            = "grafana"
}

resource "google_compute_global_address" "postgres_private_ip_address" {
  address_type  = "INTERNAL"
  name          = "postgres-private-ip-address"
  network       = google_compute_network.sql_network.id
  prefix_length = 16
  provider      = google-beta
  purpose       = "VPC_PEERING"
}

resource "google_compute_network" "sql_network" {
  name     = "sql-network"
  provider = google-beta
}

resource "google_compute_firewall" "default" {
  name    = "allow-mqtt"
  network = google_compute_network.sql_network.name

  allow {
    protocol = "tcp"
    ports    = ["21883", "21884"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_service_networking_connection" "sql_network_connection" {
  network                 = google_compute_network.sql_network.id
  provider                = google-beta-sql-network-workaround
  reserved_peering_ranges = [google_compute_global_address.postgres_private_ip_address.name]
  service                 = "servicenetworking.googleapis.com"
}

# Run migrations for the first time.
resource "terraform_data" "run_migrations" {
  depends_on = [google_sql_database.database]
  provisioner "local-exec" {
    # Relative to DSS terraform project root.
    command = file("modules/db/run-migrations.sh")
    environment = {
      DATABASE_URL       = local.db_conn_str_auth_proxy,
      DB_CONNECTION_NAME = local.db_connection_name,
      CREDENTIALS_FILE   = var.credentials_file
    }
  }
}

# Re-run migrations after database initialization.
#
# Tracked as a separate resource so that followup migrations can be run
# by simply destroying and re-applying this resource. The destroy/re-apply
# approach doesn't work for the initial migrations resource since other
# resources depend on initial migrations and they would have to be deleted
# too if initial migrations were, hence this duplicate.
#
# Upon database creation, migrations will be run twice, but this is not a
# problem because diesel only runs new migrations upon subsequent calls to the
# same database.
resource "terraform_data" "re_run_migrations" {
  depends_on = [terraform_data.run_migrations]
  provisioner "local-exec" {
    command = file("modules/db/run-migrations.sh")
    environment = {
      DATABASE_URL       = local.db_conn_str_auth_proxy,
      DB_CONNECTION_NAME = local.db_connection_name,
      CREDENTIALS_FILE   = var.credentials_file
    }
  }
}

resource "google_compute_subnetwork" "sql_connector_subnetwork" {
  name          = "sql-connector-subnetwork"
  ip_cidr_range = "10.8.0.0/28"
  region        = var.region
  network       = google_compute_network.sql_network.id
}

resource "google_project_service" "vpc" {
  provider           = google-beta
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

resource "google_vpc_access_connector" "sql_vpc_connector" {
  depends_on = [terraform_data.run_migrations, google_project_service.vpc]
  name       = "sql-vpc-connector"
  subnet {
    name = google_compute_subnetwork.sql_connector_subnetwork.name
  }
}

resource "google_compute_router" "default" {
  provider = google-beta
  name     = "cr-static-ip-router"
  network  = google_compute_network.sql_network.name
  region   = google_compute_subnetwork.sql_connector_subnetwork.region
}

resource "google_compute_address" "default" {
  provider = google-beta
  name     = "cr-static-ip-addr"
  region   = google_compute_subnetwork.sql_connector_subnetwork.region
}

resource "google_compute_router_nat" "default" {
  provider = google-beta
  name     = "cr-static-nat"
  router   = google_compute_router.default.name
  region   = google_compute_subnetwork.sql_connector_subnetwork.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.default.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.sql_connector_subnetwork.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

