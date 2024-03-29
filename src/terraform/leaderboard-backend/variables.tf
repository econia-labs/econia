variable "project" {}

variable "db_root_password" {}

variable "db_admin_public_ip" {}

variable "postgrest_max_rows" {
  default = 100
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
