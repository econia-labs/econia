output "mosquitto_url" {
  value = format("ws://%s:21883",terraform_data.instance.ip)
}
