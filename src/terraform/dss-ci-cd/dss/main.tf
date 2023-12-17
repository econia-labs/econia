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
  source           = "./modules/db"
}
