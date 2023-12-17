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

resource "google_compute_instance" "runner" {
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  machine_type = "e2-standard-2"
  metadata_startup_script = join("\n", [
    "ORGANIZATION_ID=${var.organization_id}",
    "BILLING_ACCOUNT_ID=${var.billing_account_id}",
    "PROJECT_ID=${var.project_id}",
    "PROJECT_NAME=${var.project_name}",
    "DB_ROOT_PASSWORD=${var.db_root_password}",
    "APTOS_NETWORK=${var.aptos_network}",
    "ECONIA_ADDRESS=${var.econia_address}",
    "STARTING_VERSION=${var.starting_version}",
    "GRPC_DATA_SERVICE_ADDRESS=${var.grpc_data_service_address}",
    "GRPC_AUTH_TOKEN=${var.grpc_auth_token}",
    file("startup-script.sh")
    ]
  )
  name = "runner"
  network_interface {
    access_config {}
    network = "default"
  }
  service_account {
    email  = "terraform@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
