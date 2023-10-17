output "postgres_public_ip" {
  value = local.postgres_public_ip
}

output "db_admin_conn_str" {
  description = "Connection string database admin can use for public access."
  value       = local.db_admin_conn_str
}