output "mosquitto_url" {
  value = format("%s%s",replace(google_cloud_run_v2_service.mosquitto.uri, "http", "mqtt"), ":21883")
}
