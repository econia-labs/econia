variable "project" {}

variable "db_root_password" {}

variable "db_admin_public_ip" {}

variable "credentials_file" {
  default = "gcp-key.json"
}

variable "ws_jwt_secret" {
  default = "econia_0000000000000000000000000"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}
