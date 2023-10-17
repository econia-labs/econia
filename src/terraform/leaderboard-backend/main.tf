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

provider "google-beta" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
}

locals {
  db_conn_str_admin = replace(
    local.db_conn_str_base,
    "IP_ADDRESS",
    "${local.postgres_public_ip}"
  )
  db_conn_str_base = join("", [
    "postgres://postgres:${var.db_root_password}@",
    "IP_ADDRESS:5432/econia"
  ])
  db_conn_str_private = replace(
    local.db_conn_str_base,
    "IP_ADDRESS",
    "${local.postgres_private_ip}"
  )
  econia_repo_root            = "../../.."
  migrations_dir              = "src/rust/dbv2"
  postgres_private_ip         = google_sql_database_instance.postgres.private_ip_address
  postgres_public_ip          = google_sql_database_instance.postgres.public_ip_address
  processor_config_path_src   = "src/docker/processor/config.yaml"
  processor_config_path_mount = "/mnt/disks/processor/data/config.yaml"
  processor_disk_device_path  = "/dev/disk/by-id/google-${local.processor_disk_name}"
  processor_disk_name         = "processor-disk"
  ssh_pubkey                  = "ssh/gcp.pub"
  ssh_secret                  = "ssh/gcp"
  ssh_username                = "bootstrapper"
  terraform_dir               = "src/terraform/leaderboard-backend"
}

resource "terraform_data" "run_migrations" {
  depends_on = [google_sql_database.database]
  provisioner "local-exec" {
    environment = {
      DATABASE_URL = local.db_conn_str_admin
    }
    working_dir = "${local.econia_repo_root}/${local.migrations_dir}"
    command     = "diesel database reset"
  }
}

resource "google_sql_database" "database" {
  deletion_policy = "ABANDON"
  instance        = google_sql_database_instance.postgres.name
  name            = "econia"
}

resource "google_sql_database_instance" "postgres" {
  database_version    = "POSTGRES_14"
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.sql_network_connection,
    terraform_data.config_environment,
  ]
  provider      = google-beta
  root_password = var.db_root_password
  settings {
    ip_configuration {
      authorized_networks {
        value = var.db_admin_public_ip
      }
      ipv4_enabled    = true
      private_network = google_compute_network.sql_network.id
    }
    tier = "db-f1-micro"
  }
}

resource "google_service_networking_connection" "sql_network_connection" {
  network                 = google_compute_network.sql_network.id
  provider                = google-beta
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  service                 = "servicenetworking.googleapis.com"
}

resource "google_compute_global_address" "private_ip_address" {
  address_type  = "INTERNAL"
  name          = "private-ip-address"
  network       = google_compute_network.sql_network.id
  provider      = google-beta
  prefix_length = 16
  purpose       = "VPC_PEERING"
}

resource "google_compute_network" "sql_network" {
  name     = "sql-network"
  provider = google-beta
}

resource "terraform_data" "build_processor" {
  depends_on = [google_artifact_registry_repository.images]
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit .",
      "--config ${local.terraform_dir}/cloudbuild.processor.yaml",
      "--substitutions _REGION=${var.region}"
    ])
    environment = {
      PROJECT_ID = var.project
    }
    working_dir = local.econia_repo_root
  }
}

resource "terraform_data" "build_aggregator" {
  depends_on = [google_artifact_registry_repository.images]
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit .",
      "--config ${local.terraform_dir}/cloudbuild.aggregator.yaml",
      "--substitutions _REGION=${var.region}"
    ])
    environment = {
      PROJECT_ID = var.project
    }
    working_dir = local.econia_repo_root
  }
}

resource "google_artifact_registry_repository" "images" {
  depends_on    = [terraform_data.config_environment]
  location      = var.region
  repository_id = "images"
  format        = "DOCKER"
}

resource "terraform_data" "config_environment" {
  depends_on = [terraform_data.config_environment]
  provisioner "local-exec" {
    command = join(" && ", [
      "gcloud config set project ${var.project}",
      "gcloud services enable artifactregistry.googleapis.com",
      "gcloud services enable cloudbuild.googleapis.com",
      "gcloud services enable cloudresourcemanager.googleapis.com",
      "gcloud services enable compute.googleapis.com",
      "gcloud services enable servicenetworking.googleapis.com",
      "gcloud services enable sqladmin.googleapis.com",
      "rm -rf ssh",
      "mkdir ssh",
      "ssh-keygen -t rsa -f ${local.ssh_secret} -C ${local.ssh_username} -b 2048 -q -N \"\"",
      "gcloud config set artifacts/location ${var.region}",
      "gcloud config set compute/zone ${var.zone}",
      "gcloud config set run/region ${var.zone}",
    ])
  }
}

resource "google_compute_disk" "processor_disk" {
  name = "processor-disk"
  size = 1
}

resource "google_compute_instance" "config_bootstrapper" {
  attached_disk {
    source      = "processor-disk"
    device_name = "processor-disk"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    private_key = file(local.ssh_secret)
    type        = "ssh"
    user        = local.ssh_username
  }
  depends_on = [
    google_compute_disk.processor_disk,
    google_compute_firewall.bootstrapper_ssh,
    terraform_data.config_environment,
  ]
  metadata = {
    ssh-keys = "${local.ssh_username}:${file(local.ssh_pubkey)}"
  }
  machine_type = "n2-standard-2"
  name         = "config-bootstrapper"
  network_interface {
    network = "default"
    access_config {}
  }
  provisioner "file" {
    source      = "${local.econia_repo_root}/${local.processor_config_path_src}"
    destination = "/home/${local.ssh_username}/config.yaml"
  }
  # Format and mount disk, copy config into it.
  # https://cloud.google.com/compute/docs/disks/format-mount-disk-linux#format_linux
  # https://medium.com/@DazWilkin/compute-engine-identifying-your-devices-aeae6c01a4d7
  provisioner "remote-exec" {
    inline = [
      join(" ", [
        "sudo mkfs.ext4",
        "-m 0",
        "-E lazy_itable_init=0,lazy_journal_init=0,discard",
        "${local.processor_disk_device_path}"
      ]),
      "sudo mkdir -p /mnt/disks/processor",
      join(" ", [
        "sudo mount -o",
        "discard,defaults",
        "${local.processor_disk_device_path}",
        "/mnt/disks/processor"
      ]),
      "sudo chmod a+w /mnt/disks/processor",
      "mkdir /mnt/disks/processor/data",
      # Substitute private connection string into config.
      join(" ", [
        "sed -E",
        join("", [
          "'s/(postgres_connection_string: )(.+)/\\1",
          # Escape forward slashes in private connection string.
          replace(local.db_conn_str_private, "/", "\\/"),
          "/g'",
        ]),
        "/home/${local.ssh_username}/config.yaml >",
        "${local.processor_config_path_mount}"
      ]),
      "echo Processor config:",
      "while read line; do ",
      "echo \"$line\"",
      "done<${local.processor_config_path_mount}"
    ]
  }
}

resource "google_compute_firewall" "bootstrapper_ssh" {
  name    = "bootstrapper-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [var.db_admin_public_ip]
}
