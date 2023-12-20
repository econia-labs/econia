resource "google_cloud_run_v2_service" "grafana" {
  depends_on = [var.migrations_complete]
  location   = var.region
  name       = "grafana"
  template {
    containers {
      image = "grafana/grafana-enterprise"
      env {
        name  = "GF_DATABASE_TYPE"
        value = "postgres"
      }
      env {
        name  = "GF_DATABASE_URL"
        value = var.db_conn_str_private_grafana
      }
      env {
        name  = "GF_SECURITY_ADMIN_PASSWORD"
        value = var.grafana_admin_password
      }
      ports {
        container_port = 3000
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

resource "google_cloud_run_service_iam_policy" "no_auth_grafana" {
  location    = google_cloud_run_v2_service.grafana.location
  project     = google_cloud_run_v2_service.grafana.project
  service     = google_cloud_run_v2_service.grafana.name
  policy_data = var.no_auth_policy_data
}
