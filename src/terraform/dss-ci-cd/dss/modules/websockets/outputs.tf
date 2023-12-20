output "websockets_url" {
  value = replace(google_cloud_run_v2_service.websockets.uri, "https", "wss")
}
