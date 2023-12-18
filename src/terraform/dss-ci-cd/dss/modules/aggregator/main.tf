resource "terraform_data" "image" {
  # To prevent out-of-order deletion via provisioner command.
  depends_on = [var.repository_created]
  input      = "${var.repository_id}/aggregator" # Image ID.
  provisioner "local-exec" {
    command = join(" ", [
      "gcloud builds submit econia",
      "--config cloudbuild.yaml",
      "--substitutions",
      join(",", [
        "_DOCKERFILE=aggregator/Dockerfile",
        "_IMAGE_ID=${self.input}"
      ])
    ])
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud artifacts docker images delete ${self.output} --quiet"
  }
}

# https://github.com/hashicorp/terraform-provider-google/issues/5832
resource "terraform_data" "instance" {
  depends_on = [var.migrations_complete]
  provisioner "local-exec" {
    command = join(" && ", [
      join(" ", [
        "gcloud compute instances create-with-container aggregator",
        "--container-env",
        join(",", [
          "APTOS_NETWORK=${var.aptos_network}",
          "DATABASE_URL=${var.db_conn_str_private}",
        ]),
        "--container-image ${terraform_data.image.output}",
        "--zone ${var.zone}"
      ])
    ])
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud compute instances delete aggregator --quiet"
  }
}
