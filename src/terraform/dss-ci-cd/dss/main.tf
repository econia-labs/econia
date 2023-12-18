terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.8.0"
    }
  }
  required_version = ">= 0.12, < 2.0.0"
}

locals {
  credentials_file = "service-account-key.json"
  region           = "us-central1"
  zone             = "us-central1-c"
}

provider "google" {
  credentials = file(local.credentials_file)
  project     = var.project_id
  region      = local.region
  zone        = local.zone
}

module "db" {
  db_root_password = var.db_root_password
  credentials_file = local.credentials_file
  region           = local.region
  source           = "./modules/db"
}

module "artifact_registry" {
  project_id = var.project_id
  region     = local.region
  source     = "./modules/artifact_registry"
}

module "processor" {
  db_conn_str_private       = module.db.db_conn_str_private
  econia_address            = var.econia_address
  migrations_complete       = module.db.migrations_complete
  grpc_auth_token           = var.grpc_auth_token
  grpc_data_service_address = var.grpc_data_service_address
  repository_id             = module.artifact_registry.repository_id
  source                    = "./modules/processor"
  starting_version          = var.starting_version
}

module "aggregator" {
  aptos_network       = var.aptos_network
  db_conn_str_private = module.db.db_conn_str_private
  migrations_complete = module.db.migrations_complete
  repository_id       = module.artifact_registry.repository_id
  source              = "./modules/aggregator"
}

module "no_auth_policy" {
  source = "./modules/no_auth_policy"
}

module "postgrest" {
  db_conn_str_private  = module.db.db_conn_str_private
  no_auth_policy_data  = module.no_auth_policy.policy_data
  postgrest_max_rows   = var.postgrest_max_rows
  region               = local.region
  source               = "./modules/postgrest"
  sql_vpc_connector_id = module.db.sql_vpc_connector_id
}