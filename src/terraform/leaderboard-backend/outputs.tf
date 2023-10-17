output "db_conn_str_admin" {
  value = local.db_conn_str_admin
}

output "db_conn_str_private" {
  value = local.db_conn_str_private
}

output "postgres_public_ip" {
  value = local.postgres_public_ip
}

output "postgrest_url" {
    value = google_cloud_run_v2_service.postgrest.uri
}