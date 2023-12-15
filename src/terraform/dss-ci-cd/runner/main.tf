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
  project     = var.project
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
    file("project-vars.sh"),
    file("scripts/startup-script.sh")
    ]
  )
  name = "runner"
  network_interface {
    access_config {}
    network = "default"
  }
  service_account {
    email  = "terraform@${var.project}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
