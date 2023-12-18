output "db_connection_name" {
  value = local.db_connection_name
}

output "db_conn_str_auth_proxy" {
  value = local.db_conn_str_auth_proxy
}

output "db_conn_str_private" {
  value = local.db_conn_str_private
}

output "migrations_complete" {
  depends_on = [terraform_data.run_migrations]
  value      = true
}

output "sql_vpc_connector_id" {
  value = google_vpc_access_connector.sql_vpc_connector.id
}