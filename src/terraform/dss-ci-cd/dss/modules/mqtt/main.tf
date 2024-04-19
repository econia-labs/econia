resource "terraform_data" "image" {
  # To prevent out-of-order deletion via provisioner command.
  depends_on = [var.repository_created]
  input      = "${var.repository_id}/mqtt" # Image ID.
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit econia",
      "--config cloudbuild.yaml",
      "--substitutions",
      join(",", [
        "_DOCKERFILE=mqtt/Dockerfile",
        "_IMAGE_ID=${self.input}"
      ])
    ])
  }
  provisioner "local-exec" {
    when = destroy
    command = join("\n", [
      "result=$(gcloud artifacts docker images list --filter IMAGE=${self.output})",
      "if [ -n \"$result\" ]; then",
      "gcloud artifacts docker images delete ${self.output} --quiet",
      "fi"
    ])
  }
}

resource "terraform_data" "instance" {
  # Store zone since variables not accessible at destroy time.
  input = var.zone
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud compute instances create-with-container mqtt",
      "--container-env",
      join(",", [
        "MQTT_PASSWORD=${var.mosquitto_password}",
        "DATABASE_URL=${var.db_conn_str_private}",
        "MQTT_PRICE_LEVELS=yes"
      ]),
      "--container-image ${terraform_data.image.output}",
      "--network ${var.sql_network_id}",
      "--zone ${var.zone}"
    ])
  }
  provisioner "local-exec" {
    command = join("\n", [
      "result=$(gcloud compute instances list --filter NAME=mqtt)",
      "if [ -n \"$result\" ]; then",
      join(" ", [
        "gcloud compute instances delete mqtt",
        "--quiet",
        "--zone ${self.output}"
      ]),
      "fi"
    ])
    when = destroy
  }
}

data "external" "ip" {
  depends_on = [terraform_data.instance]
  program = [
    "bash",
    "-c",
    "gcloud compute instances list --filter name=mqtt --format 'json(networkInterfaces[0].accessConfigs[0].natIP)' | jq '.[0].networkInterfaces[0].accessConfigs[0]'",
  ]
}
