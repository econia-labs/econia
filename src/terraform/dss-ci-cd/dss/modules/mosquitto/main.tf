resource "terraform_data" "image" {
  # To prevent out-of-order deletion via provisioner command.
  depends_on = [var.repository_created]
  input      = "${var.repository_id}/mosquitto" # Image ID.
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit econia",
      "--config cloudbuild.yaml",
      "--substitutions",
      join(",", [
        "_DOCKERFILE=mqtt/Dockerfile.mosquitto",
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

resource "google_cloud_run_v2_service" "mosquitto" {
  depends_on = []
  location   = var.region
  name       = "mosquitto"
  template {
    containers {
      image = "${terraform_data.image.output}"
      env {
        name  = "MQTT_PASSWORD"
        value = var.mosquitto_password
      }
      ports {
        container_port = 21883
      }
    }
    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth_mosquitto" {
  location    = google_cloud_run_v2_service.mosquitto.location
  project     = google_cloud_run_v2_service.mosquitto.project
  service     = google_cloud_run_v2_service.mosquitto.name
  policy_data = var.no_auth_policy_data
}
