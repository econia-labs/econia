output "db_connection_name" {
  value = local.db_connection_name
}

output "db_conn_str_auth_proxy" {
  value = local.db_conn_str_auth_proxy
}

output "db_conn_str_private" {
  value = local.db_conn_str_private
}

output "db_conn_str_private_grafana" {
  value = local.db_conn_str_private_grafana
}

output "migrations_complete" {
  value = terraform_data.run_migrations
}

output "sql_vpc_connector_id" {
  value = google_vpc_access_connector.sql_vpc_connector.id
}

output "sql_network_id" {
  value = google_compute_network.sql_network.id
}
