resource "google_cloud_run_v2_service" "websockets" {
  depends_on = [var.migrations_complete]
  location   = var.region
  name       = "websockets"
  template {
    containers {
      image = "diogob/postgres-websockets:0.11.2.1"
      env {
        name  = "PGWS_CHECK_LISTENER_INTERVAL"
        value = 1000
      }
      env {
        name  = "PGWS_DB_URI"
        value = var.db_conn_str_private
      }
      env {
        name  = "PGWS_JWT_SECRET"
        value = var.websockets_jwt_secret
      }
      env {
        name  = "PGWS_LISTEN_CHANNEL"
        value = "econiaws"
      }
      ports {
        container_port = 3000
      }
      resources {
        limits = {
          cpu    = "2"
          memory = "1024Mi"
        }
      }
    }
    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }
    vpc_access {
      connector = var.sql_vpc_connector_id
      egress    = "ALL_TRAFFIC"
    }
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth_postgrest" {
  location    = google_cloud_run_v2_service.websockets.location
  project     = google_cloud_run_v2_service.websockets.project
  service     = google_cloud_run_v2_service.websockets.name
  policy_data = var.no_auth_policy_data
}
