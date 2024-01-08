resource "terraform_data" "image" {
  # To prevent out-of-order deletion via provisioner command.
  depends_on = [var.repository_created]
  input      = "${var.repository_id}/processor" # Image ID.
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit econia",
      "--config cloudbuild.yaml",
      "--substitutions",
      join(",", [
        "_DOCKERFILE=processor/Dockerfile",
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

# https://github.com/hashicorp/terraform-provider-google/issues/5832
resource "terraform_data" "instance" {
  depends_on = [var.migrations_complete]
  # Store zone since variables not accessible at destroy time.
  input = var.zone
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud compute instances create-with-container processor",
      "--container-env",
      join(",", [
        "DATABASE_URL=${var.db_conn_str_private}",
        "ECONIA_ADDRESS=${var.econia_address}",
        "GRPC_AUTH_TOKEN=${var.grpc_auth_token}",
        "GRPC_DATA_SERVICE_URL=${var.grpc_data_service_url}",
        "STARTING_VERSION=${var.starting_version}",
      ]),
      "--container-image ${terraform_data.image.output}",
      "--network ${var.sql_network_id}",
      "--zone ${var.zone}"
    ])
  }
  provisioner "local-exec" {
    command = join("\n", [
      "result=$(gcloud compute instances list --filter NAME=processor)",
      "if [ -n \"$result\" ]; then",
      join(" ", [
        "gcloud compute instances delete processor",
        "--quiet",
        "--zone ${self.output}"
      ]),
      "fi"
    ])
    when = destroy
  }
}
