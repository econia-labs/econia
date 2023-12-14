terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.8.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

module "db" {
  credentials_file = var.credentials_file
  project          = var.project
  region           = var.region
  source           = "./modules/db"
}
