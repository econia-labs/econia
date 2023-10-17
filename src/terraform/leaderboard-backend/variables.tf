variable "project" {}

variable "db_root_password" {}

variable "db_admin_public_ip" {}

variable "migrations_dir" {
  default = "/src/rust/dbv2"
}

variable "econia_repo_root" {
  default = "../../../"
}

variable "terraform_dir" {
  default = "src/terraform/leaderboard-backend"
}

variable "credentials_file" {
  default = "gcp-key.json"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}
