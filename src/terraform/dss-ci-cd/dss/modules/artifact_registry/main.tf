locals {
  repository_id = "${var.region}-docker.pkg.dev/${var.project_id}/images"
}

resource "google_artifact_registry_repository" "images" {
  location      = var.region
  repository_id = "images"
  format        = "DOCKER"
}
