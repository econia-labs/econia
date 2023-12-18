resource "google_cloud_run_v2_service" "postgrest" {
  location = var.region
  name     = "postgrest"
  template {
    containers {
      image = "postgrest/postgrest:v11.2.1"
      env {
        name  = "PGRST_DB_ANON_ROLE"
        value = "web_anon"
      }
      env {
        name  = "PGRST_DB_MAX_ROWS"
        value = var.postgrest_max_rows
      }
      env {
        name  = "PGRST_DB_SCHEMA"
        value = "api"
      }
      env {
        name  = "PGRST_DB_URI"
        value = var.db_conn_str_private
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

resource "google_cloud_run_service_iam_policy" "no_auth_postgrest" {
  location    = google_cloud_run_v2_service.postgrest.location
  project     = google_cloud_run_v2_service.postgrest.project
  service     = google_cloud_run_v2_service.postgrest.name
  policy_data = var.no_auth_policy_data
}
