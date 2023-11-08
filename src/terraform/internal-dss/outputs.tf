output "project" {
  value = var.project
}

output "db_conn_str_admin" {
  value = local.db_conn_str_admin
}

output "postgrest_url" {
  value = google_cloud_run_v2_service.postgrest.uri
}

output "websockets_url" {
  value = replace(google_cloud_run_v2_service.websockets.uri, "https", "wss")
}
