output "mqtt_ip" {
  value = data.external.ip.result.natIP
}
