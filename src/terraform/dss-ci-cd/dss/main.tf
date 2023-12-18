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
  db_conn_str_private       = module.db.db_conn_str_private
  econia_address            = var.econia_address
  grpc_auth_token           = var.grpc_auth_token
  grpc_data_service_address = var.grpc_data_service_address
  repository_id             = module.artifact_registry.repository_id
  source                    = "./modules/processor"
  starting_version          = var.starting_version
}
