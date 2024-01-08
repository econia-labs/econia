output "repository_id" {
  value = local.repository_id
}

output "repository_created" {
  value = google_artifact_registry_repository.images
}
