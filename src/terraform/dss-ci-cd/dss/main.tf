terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.8.0"
    }
  }
  required_version = ">= 0.12, < 2.0.0"
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "db" {
  db_root_password = var.db_root_password
  credentials_file = var.credentials_file
  region           = var.region
  source           = "./modules/db"
}

module "artifact_registry" {
  project_id = var.project_id
  region     = var.region
  source     = "./modules/artifact_registry"
}

module "processor" {
  db_conn_str_private   = module.db.db_conn_str_private
  econia_address        = var.econia_address
  migrations_complete   = module.db.migrations_complete
  grpc_auth_token       = var.grpc_auth_token
  grpc_data_service_url = var.grpc_data_service_url
  repository_created    = module.artifact_registry.repository_created
  repository_id         = module.artifact_registry.repository_id
  source                = "./modules/processor"
  sql_network_id        = module.db.sql_network_id
  starting_version      = var.starting_version
  zone                  = var.zone
}

module "aggregator" {
  aptos_network       = var.aptos_network
  db_conn_str_private = module.db.db_conn_str_private
  migrations_complete = module.db.migrations_complete
  repository_created  = module.artifact_registry.repository_created
  repository_id       = module.artifact_registry.repository_id
  source              = "./modules/aggregator"
  sql_network_id      = module.db.sql_network_id
  zone                = var.zone
}

module "no_auth_policy" {
  source = "./modules/no_auth_policy"
}

module "postgrest" {
  db_conn_str_private  = module.db.db_conn_str_private
  migrations_complete  = module.db.migrations_complete
  no_auth_policy_data  = module.no_auth_policy.policy_data
  postgrest_max_rows   = var.postgrest_max_rows
  region               = var.region
  source               = "./modules/postgrest"
  sql_vpc_connector_id = module.db.sql_vpc_connector_id
}

module "mqtt" {
  db_conn_str_private   = module.db.db_conn_str_private
  mosquitto_password    = var.mosquitto_password
  repository_created    = module.artifact_registry.repository_created
  repository_id         = module.artifact_registry.repository_id
  source                = "./modules/mqtt"
  sql_network_id        = module.db.sql_network_id
  zone                  = var.zone
}

module "grafana" {
  db_conn_str_private_grafana = module.db.db_conn_str_private_grafana
  db_private_ip_and_port      = module.db.db_private_ip_and_port
  grafana_admin_password      = var.grafana_admin_password
  grafana_public_password     = var.grafana_public_password
  migrations_complete         = module.db.migrations_complete
  no_auth_policy_data         = module.no_auth_policy.policy_data
  region                      = var.region
  source                      = "./modules/grafana"
  sql_vpc_connector_id        = module.db.sql_vpc_connector_id
}
