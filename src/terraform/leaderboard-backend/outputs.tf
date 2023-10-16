output "postgres_public_ip" {
  value = google_sql_database_instance.postgres.public_ip_address
}

output "db_admin_conn_str" {
  description = "Connection string database admin can use for public access."
  value = "${
    "postgres://postgres:${var.db_root_password}@"}${
    "${google_sql_database_instance.postgres.public_ip_address}:5432/econia"
  }"
}