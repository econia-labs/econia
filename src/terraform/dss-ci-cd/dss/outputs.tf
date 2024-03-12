output "db_connection_name" {
  value = module.db.db_connection_name
}

output "db_conn_str_auth_proxy" {
  sensitive = true
  value     = module.db.db_conn_str_auth_proxy
}

output "db_conn_str_private" {
  sensitive = true
  value     = module.db.db_conn_str_private
}

output "organization_id" {
  value = var.organization_id
}

output "billing_account_id" {
  value = var.billing_account_id
}

output "project_id" {
  value = var.project_id
}

output "project_name" {
  value = var.project_name
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "db_root_password" {
  sensitive = true
  value     = var.db_root_password
}

output "aptos_network" {
  value = var.aptos_network
}

output "econia_address" {
  value = var.econia_address
}

output "starting_version" {
  value = var.starting_version
}

output "grpc_data_service_url" {
  value = var.grpc_data_service_url
}

output "grpc_auth_token" {
  sensitive = true
  value     = var.grpc_auth_token
}

output "postgrest_max_rows" {
  value = var.postgrest_max_rows
}

output "postgrest_url" {
  value = module.postgrest.postgrest_url
}

output "grafana_url" {
  value = module.grafana.grafana_url
}

output "grafana_admin_password" {
  sensitive = true
  value     = var.grafana_admin_password
}

output "grafana_public_password" {
  sensitive = true
  value     = var.grafana_public_password
}

output "dss_source_rev" {
  value = var.dss_source_rev
}

output "terraform_project_rev" {
  value = var.terraform_project_rev
}

output "mosquitto_password" {
  sensitive = true
  value = var.mosquitto_password
}

output "mqtt_ip" {
  value = module.mqtt.mqtt_ip
}
