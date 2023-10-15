output "postgres_public_ip" {
  value = google_sql_database_instance.postgres.public_ip_address
}