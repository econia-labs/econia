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

locals {
  db_admin_conn_str = join("", [
    "postgres://postgres:${var.db_root_password}@",
    "${local.postgres_public_ip}:5432/econia"
  ])
  db_private_conn_str = join("", [
    "postgres://postgres:${var.db_root_password}@",
    "${local.postgres_private_ip}:5432/econia"
  ])
  # https://medium.com/@DazWilkin/compute-engine-identifying-your-devices-aeae6c01a4d7
  processor_disk_device_path = "/dev/disk/by-id/google-${local.processor_disk_name}"
  processor_disk_name        = "processor-disk"
  ssh_username               = "bootstrapper"
  postgres_private_ip        = google_sql_database_instance.postgres.private_ip_address
  postgres_public_ip         = google_sql_database_instance.postgres.public_ip_address
  processor_config_path      = "src/docker/processor/config.yaml"
  ssh_secret                 = "ssh/gcp"
  ssh_pubkey                 = "ssh/gcp.pub"
}

resource "null_resource" "run_migrations" {
  depends_on = [google_sql_database.database]
  provisioner "local-exec" {
    environment = {
      DATABASE_URL = local.db_admin_conn_str
    }
    working_dir = "${var.econia_repo_root}/${var.migrations_dir}"
    command     = "diesel database reset"
  }
}

resource "google_sql_database" "database" {
  name     = "econia"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_database_instance" "postgres" {
  database_version    = "POSTGRES_14"
  deletion_protection = false
  depends_on          = [null_resource.config_environment]
  root_password       = var.db_root_password
  settings {
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = var.db_admin_public_ip
      }
    }
    tier = "db-f1-micro"
  }
}

resource "null_resource" "build_processor" {
  depends_on = [google_artifact_registry_repository.images]
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit .",
      "--config ${var.terraform_dir}/cloudbuild.processor.yaml",
      "--substitutions _REGION=${var.region}"
    ])
    environment = {
      PROJECT_ID = var.project
    }
    working_dir = var.econia_repo_root
  }
}

resource "null_resource" "build_aggregator" {
  depends_on = [google_artifact_registry_repository.images]
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit .",
      "--config ${var.terraform_dir}/cloudbuild.aggregator.yaml",
      "--substitutions _REGION=${var.region}"
    ])
    environment = {
      PROJECT_ID = var.project
    }
    working_dir = var.econia_repo_root
  }
}

resource "google_artifact_registry_repository" "images" {
  depends_on    = [null_resource.config_environment]
  location      = var.region
  repository_id = "images"
  format        = "DOCKER"
}

resource "null_resource" "config_environment" {
  depends_on = [null_resource.config_environment]
  provisioner "local-exec" {
    command = join(" && ", [
      "gcloud config set project ${var.project}",
      "gcloud services enable artifactregistry.googleapis.com",
      "gcloud services enable cloudbuild.googleapis.com",
      "gcloud services enable compute.googleapis.com",
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
    google_compute_firewall.bootstrapper_ssh,
    null_resource.config_environment,
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
    source      = "${var.econia_repo_root}/${local.processor_config_path}"
    destination = "/home/${local.ssh_username}/config.yaml"
  }
  provisioner "remote-exec" {
    inline = [
      # Format the disk.
      join(" ", [
        "sudo mkfs.ext4",
        "-m 0",
        "-E lazy_itable_init=0,lazy_journal_init=0,discard",
        "${local.processor_disk_device_path}"
      ]),
      "sudo mkdir -p /mnt/disks/processor",
      # Mount it.
      join(" ", [
        "sudo mount -o",
        "discard,defaults",
        "${local.processor_disk_device_path}",
        "/mnt/disks/processor"
      ]),
      "sudo chmod a+w /mnt/disks/processor",
      "mkdir /mnt/disks/processor/data",
      # Edit the processor config connection string.
      join(" ", [
        "sed -E",
        join("", [
            "'s/(postgres_connection_string: )(.+)/\\1",
            # Escape forward slashes in private connection string.
            join("", [
                "postgres:\\/\\/postgres:${var.db_root_password}@",
                "${local.postgres_private_ip}:5432\\/econia"
            ]),
            "/g'",
        ]),
        "/home/${local.ssh_username}/config.yaml >",
        "/mnt/disks/processor/data/config.yaml"
      ]),
      "echo Processor config:",
      "while read line; do echo \"$line\"; done</mnt/disks/processor/data/config.yaml"
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
