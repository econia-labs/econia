output "db_conn_str_admin" {
  description = "Connection string database admin can use for public access."
  value       = local.db_conn_str_admin
}

output "postgres_public_ip" {
  value = local.postgres_public_ip
}